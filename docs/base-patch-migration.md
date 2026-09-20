# OpenCCU-Base patch migration

Migrate **one patch at a time**. Merge its Base PR first, then merge the
OpenCCU cleanup PR (removal, pin and archive hash together), before starting
another patch. Do not combine unrelated fixes or automatically merge PRs.

## Durable state and responsibilities

- `docs/base-patch-migration/state.json`: verified checkpoint, completed PR
  pairs and the current migration. This is a checkpoint, not live GitHub state.
- `docs/base-patch-migration/index.json`: generated patch names, content hashes,
  changed files and added/removed line counts. No source copies or full logs.
- `scripts/base-patch-migration.py`: local preparation and validation helpers.

Before writes, fetch both repositories, verify live PR merge state, confirm
the current OpenCCU pin and verify the authenticated GitHub user is
`jens-maus`. Use that identity for commits and PRs.

The helper does not create commits, push branches, query credentials, open PRs
or merge them. Those actions remain explicit steps through the configured
GitHub connection. No new credentials are required by this helper.

## Small, read-only reports

Run from the OpenCCU checkout (or supply `--repo PATH` before the command):

```sh
python3 scripts/base-patch-migration.py status
python3 scripts/base-patch-migration.py index
python3 scripts/base-patch-migration.py candidates --limit 5
python3 scripts/base-patch-migration.py inspect 0102
```

`index` checks freshness; `index --write` regenerates it when patch contents or
the series change. Include the updated index in a cleanup PR. `inspect` prints
only one patch's metadata, a permanent source link and IDs sharing files.
File overlap is **not** proof of a semantic dependency. Inspect the actual
hunks, affected source functions, original issue/PR and nearby modifications.
Do not migrate blindly in numeric order; classify already-upstream or obsolete
patches separately. The index does not claim they all need native changes.
`candidates` is only a bounded shortlist by size and file overlap, not an
approval to migrate those patches or a substitute for technical review.

Read the full patch and additional source context only for the chosen candidate.
Keep full build/API responses in files; return only hashes, counts, status and
the relevant error excerpt. Never print whole repository trees or encoded blobs.

## Reproducible source archives

Use the **same Buildroot version as OpenCCU**, with its normal download tools
available. The existing Buildroot git download backend handles export attributes
and reproducible archive metadata; this helper does not invent another format.

```sh
python3 scripts/base-patch-migration.py archive \
  --base-repo /path/to/OpenCCU-Base \
  --buildroot /path/to/buildroot \
  --commit FULL_COMMIT_SHA
```

This uses a new isolated download cache and the local Base repository as a Git
source. It prints the archive path and SHA256. It does not change OpenCCU's pin.
The current pin's archive must match the committed `openccu-base.hash` exactly.

## Validate and compare

Requirements: Python 3.10+, GNU patch/diff/coreutils, Bash 4+, CMake, make, Tcl,
and the Python modules needed by the existing asset generators (`html2text`).
`CMAKE`, `PYTHON` and `TCLSH` may specify installed executables.

```sh
python3 scripts/base-patch-migration.py validate --archive /path/to/pinned.tar.gz

# After implementing exactly one native fix, but BEFORE its Base PR is merged:
python3 scripts/base-patch-migration.py validate \
  --archive /path/to/candidate.tar.gz \
  --candidate-commit CANDIDATE_COMMIT_SHA \
  --candidate-sha256 CANDIDATE_ARCHIVE_SHA256 --skip-patch PATCH_NUMBER

python3 scripts/base-patch-migration.py compare \
  /path/to/baseline/report.json /path/to/candidate/report.json
```

Validation verifies archive and license hashes, safely extracts the source,
runs the existing device-type/version-header tests, stages assets, checks
workspace-generated patches, applies the entire applicable series with zero
fuzz and runs the existing regression tests. The candidate mode omits only the
named rootfs patch; it never changes the tracked series. New package-level
source patches cause a stop rather than being silently ignored: use the
Buildroot `make PRODUCT=rpi3 check-openccu-base` path in that case.

The report records source/patch identities and the manifest hash. Comparison
checks every output entry's type, content, mode and symlink target. A difference
is a failure to investigate, not something to normalize away. Additional
patch-specific behavioral tests remain necessary; this is not a full firmware
build or a physical-device test.

Logs and results default to the repository's Git directory under
`base-patch-migration`; `--cache PATH` selects another local location. Do not
commit generated rootfs trees or logs. A failed run retains its diagnostic log.
Copy important reports elsewhere if the working environment may be discarded.

Only asset staging can be reused, explicitly with `--reuse-stage` and
`--toolchain-id IMMUTABLE_TOOLCHAIN_ID` (for example, a container image digest).
Use a new ID whenever tools, libraries or their configuration change. The cache
also keys the archive, staging driver and interpreter/executable hashes, and
checks cached source/rootfs manifests before reuse. With no immutable toolchain
identity, leave reuse disabled. Patch validation and tests still run every time.
Do not share a writable cache between concurrent jobs.

## Cleanup after the Base merge

Fetch the **fresh full REST PR response** from
`GET /repos/OpenCCU/OpenCCU-Base/pulls/NUMBER` through the configured GitHub
connection and save it as `base-pr.json` outside the checkout. This file is a
trusted input supplied by the operator, not an independently authenticated
signature. Verify its live `merged` status before using it.

On a clean, dedicated OpenCCU cleanup branch:

```sh
python3 scripts/base-patch-migration.py prepare-cleanup PATCH_NUMBER \
  --merge-receipt /path/to/base-pr.json \
  --base-repo /path/to/OpenCCU-Base \
  --archive /path/to/merge-commit.tar.gz
```

This checks the Base repository/branch, merge state, patch name, ancestry,
archive contents against the actual Git commit, unchanged license hashes and
clean worktree. It removes only the selected patch and its tracked workspace,
updates pin/hash/series/index and records an in-progress cleanup in the state.
Deleted patch files remain recoverable from Git. It refuses a second active
migration. Its success means **prepared, not validated**.

Run `validate` against the new pin and compare with the baseline before
committing. Do not regenerate all workspaces as a routine step. If a preceding
patch needs a refreshed context, inspect and update only that affected workspace
and regenerate/check its patch; investigate any unrelated changes.

## PR and checkpoint checklist

1. Base PR: patch number, full filename, permanent original-patch URL, technical
   explanation and validation summary. Mention pending cleanup until its PR
   exists. Review and merge Base first.
2. Cleanup PR: link the merged Base PR, state its merge SHA and new archive
   hash, show the remaining count and equivalence/regression results. Add the
   cleanup PR number to `state.json` and add the backlink to the Base PR.
3. After verifying the cleanup merge, move its state entry to `completed`,
   refresh the verified checkpoint/pin/hash and clear `in_progress`. Carry this
   small state update into the next migration's cleanup branch (or a dedicated
   checkpoint commit); never mark a merely opened PR as merged.
4. Only then choose the next candidate. For a new working session, read this
   document, the small state file and `status`; load only the selected index
   entry. Always recheck live HEADs before writes.

The previous baseline report is reusable only for the same source archive,
patch contents/order, preparation scripts and toolchain. Otherwise regenerate
it. Without an immutable toolchain identity, reuse it only within the same
unchanged working environment. Do not infer validity merely from the patch
count or branch name.

## Tests

```sh
python3 -m unittest discover -s scripts/testcases/migration -v
python3 scripts/base-patch-migration.py index
```
