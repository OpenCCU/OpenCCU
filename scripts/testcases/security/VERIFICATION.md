# Verification — GHSA-c45w-fgwq-mvq4 / OpenCCU-Base package patch

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

`rega_script_injection_test.tcl` sources the patched `hmscript_escapeString`
and `rega_escape` from a supplied rootfs (or uses reference implementations in
standalone mode), includes the *old* vulnerable escaper, and asserts the
invariant above against quote/backslash payloads.

```text
$ tclsh scripts/testcases/security/rega_script_injection_test.tcl
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

## Layer 3 — generated rootfs check

- The fix, formerly the OpenCCU rootfs patch
  `0207-WebUI-Fix-ReGaScriptInjection`, is part of OpenCCU-Base since
  [OpenCCU/OpenCCU-Base#46](https://github.com/OpenCCU/OpenCCU-Base/pull/46).
- `make PRODUCT=<product> check` generates the WebUI assets of the OpenCCU-Base
  commit pinned by `OPENCCU_BASE_VERSION` in `openccu-base.mk`
  (`buildroot-external/package/openccu-base/stage_assets.sh`), and
  `validate_rootfs.sh` checks that rootfs: generated files, compatibility
  symlinks, Tcl syntax of the 4 edited Tcl files (`info complete`, brace
  balance), the PDA ID validation, and the security regression against the
  actual helper implementations.

## Layer 4 — functional regression on the live WebUI (does legit `\` still work?)

The added `\`-escaping must not break legitimate backslash use. Verified on a dev
instance (3.87.6.20260614) by deploying the patched `hmscript.tcl` over the live
file (bind-mount; `/www` is read-only squashfs) and driving the **real JSON-RPC
API** — `SysVar.createBool`, whose `name` flows through `hmscript_escapeString`
and whose response echoes the stored `sv.Name()`. Before/after, with a positive
control:

```text
input name              UNPATCHED (control)              PATCHED
a\test\b             -> a<TAB>est\b  (\t corrupted)   -> a\test\b      (exact)
ends\                -> result:null  (create failed)  -> ends\         (exact)
x\";WriteLine(31337) -> 31337 executed (RCE)          -> stored inert  (no exec)
```

So the patch is not just non-breaking — the *unpatched* escaper silently corrupts
valid backslash data (`\t`/`\n`/… interpreted as control chars) and fails on
trailing `\`. The fix preserves every legit value exactly (ReGa decodes `\\`→`\`,
so escaper-doubling and parser-halving cancel) and neutralizes the injection.

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
tclsh scripts/testcases/security/rega_script_injection_test.tcl  # standalone layer 1
# full generated-rootfs verification:
buildroot-external/package/openccu-base/stage_assets.sh \
  /absolute/path/to/extracted/OpenCCU-Base /tmp/openccu-base-rootfs
buildroot-external/package/openccu-base/validate_rootfs.sh /tmp/openccu-base-rootfs
# layer 2: run the two scripts above via any ReGa runner (rega.exe / tclrega)
```
