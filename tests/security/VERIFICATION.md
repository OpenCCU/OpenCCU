# Verification — GHSA-c45w-fgwq-mvq4 / patch 0207-WebUI-Fix-ReGaScriptInjection

How we ensured the fix actually closes the vulnerability, without building a
full firmware image. Three independent layers, each reproducible.

## The security invariant

The WebUI generates ReGa as `var <name> = "<value>";`. The fix is correct iff
the *escaped* value can never terminate or escape that enclosing `"..."`
literal — i.e. it must contain **no unescaped `"`** and must **not end in an odd
run of `\`** (a trailing lone backslash would escape the closing quote). The
root cause was that the escapers doubled the quote but left `\` untouched, and
the PDA interface did no escaping at all.

## Layer 1 — escaper logic, isolated (`tclsh`)

`rega_script_injection_test.tcl` reproduces the patched `hmscript_escapeString`
and `rega_escape`, plus the *old* (vulnerable) escaper, and asserts the
invariant above against quote/backslash payloads.

```text
$ tclsh tests/security/rega_script_injection_test.tcl
... 22 assertions ...
ALL TESTS PASSED   (exit 0)
```

Key cases:
- patched escapers → **safe** for every payload (incl. `\"`, `\\"`,
  `\";WriteLine(31337);!`, `\\\";system.Exec("id")`);
- the **old** escaper → **unsafe** for `\";WriteLine(31337);!` (documents the CVE);
- `a\b` → `a\\b` (legitimate backslashes preserved — also fixes silent data loss);
- `json_toString` already escaped `\` → regression guard only, unchanged by the patch;
- PDA validator: `0";system.Exec("id")` → `""`, `1234` → `1234`.

## Layer 2 — real ReGa engine (the decisive test)

The string-level invariant is meaningful only if the ReGa parser behaves as
assumed. We confirmed it directly on a live engine, **non-destructively
(`WriteLine` markers only — no `system.Exec`, no writes, no state change)**,
feeding the exact bytes each escaper produces:

```text
# vulnerable output:
WriteLine("PRE");
var p = "\\";WriteLine(31337);!";        -> output:  PRE
                                                      31337      <-- INJECTED CODE RAN

# patched output:
WriteLine("PRE");
var p = "\\\";WriteLine(31337);!";       -> output:  PRE        <-- inert, 31337 never runs
```

`\\` decodes to one backslash and the following `"` closes the literal (breakout);
the patched form emits `\"`, a literal quote that stays *inside* the string, so
the would-be payload is just data.

## Layer 3 — patch hygiene

- `.orig` files are pristine upstream — byte-identical to the four target files
  in the currently-pinned OCCU (`3.89.2-1`; these files are unchanged since
  `3.87.6-3`, where this was first verified); no other patch in
  `buildroot-external/patches/occu/` touches these 4 files, so the base is correct.
- `patch -p1 --dry-run` applies cleanly against the pinned occu tree.
- The committed `.patch` matches `create_patches.sh` output (keeps CI
  `git diff --exit-code` green).
- All 4 edited Tcl files pass `info complete` (brace balance).

## Scope coverage

- **JSON-RPC** (`/api/homematic.cgi`): every method routes user strings through
  `hmscript` → fixing `hmscript_escapeString` covers the whole surface
  (`www/api/methods/**` has no raw script-building of its own).
- **PDA** (`/pda/*.cgi`): only `favId`/`favListId` are user-controlled; all other
  IDs are server-derived via `dom.GetObject`. Validating those two at the request
  entry points (`fav.cgi`, `favlist.cgi`) covers all 36 downstream sinks.
- `rega_escape`: latent (no caller today) but fixed to match.

## Reproduce

```sh
tclsh tests/security/rega_script_injection_test.tcl     # layer 1
# layer 2: run the two scripts above via any ReGa runner (rega.exe / tclrega)
```
