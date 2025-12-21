# OpenCCU LTS Maintainer Playbook

This playbook describes how to maintain **OpenCCU** with a fast-moving `master` branch and a conservative `LTS` branch, while **publishing LTS releases from the fork** `homematicip/OpenCCU-LTS` (default branch: `LTS`).

It is designed to be directly actionable (copy/paste commands).

---

## 1. Repositories and branches

### 1.1 Upstream development repository

- Repository: `OpenCCU/OpenCCU`
- Branches:
  - `master` (default; all PRs land here via **Squash & Merge**)
  - `LTS` (maintenance line; receives selected backports + periodic baseline updates)

### 1.2 LTS release repository (fork)

- Repository: `homematicip/OpenCCU-LTS` (fork of `OpenCCU/OpenCCU`)
- Branches:
  - `LTS` (default; **all LTS releases are created here**)

---

## 2. Goals and invariants

1. **All feature development** (and most changes) go to `master`.
2. **Only selected, low-risk changes** are backported from `master` to `LTS`.
3. **Periodically** (e.g., every 6 months), the LTS baseline is advanced to a known-good `master` release tag.
4. **LTS releases are published in the fork** (`homematicip/OpenCCU-LTS`) so that end users have one stable release channel.

---

## 3. Terminology

- **STS release**: A normal OpenCCU release tag created from `master` (e.g., `3.85.7.20251129`).
- **LTS baseline**: A specific STS release tag that becomes the starting point for an LTS period.
- **LTS maintenance release**: A release based on the current LTS baseline plus selected backports (bugfixes, security fixes).

---

## 4. Versioning and tagging policy

OpenCCU tags follow this shape:

```text
<MAJOR>.<MINOR>.<PATCH>.<YYYYMMDD>
```

Examples:
- `3.85.7.20251129`
- `3.83.6.20251025`

### 4.1 LTS tagging rule (recommended)

To keep update tooling simple, **do not add suffixes** such as `-lts` to the tag name unless you have confirmed all tooling accepts it.

Instead:

- **LTS baseline release**: use the same tag name as the selected STS baseline (e.g., `3.85.7.20251129`)
- **LTS maintenance releases**: keep `<MAJOR>.<MINOR>.<PATCH>` the same, but use a newer date:
  - baseline: `3.85.7.20251129`
  - maintenance #1: `3.85.7.20260215`
  - maintenance #2: `3.85.7.20260420`

This communicates:
- Compatibility line: `3.85.7`
- Build/release date: `YYYYMMDD`

### 4.2 What must be recorded for each LTS release

In release notes (and optionally in a `docs/lts/` file), record:

- Baseline STS tag (e.g., `3.85.7.20251129`)
- List of backported PRs (PR number + one-line summary)
- Any migration notes / known issues

---

## 5. Labeling and backport decision process

Recommended labels in `OpenCCU/OpenCCU`:

- `backport:LTS` — approved for backport to LTS
- `risk:low|medium|high` — risk assessment for LTS
- `backport:blocked` — desirable, but currently blocked (dependency/conflicts)

**Rule of thumb:** Only backport `risk:low` changes unless there is a compelling reason.

---

## 6. One-time local Git setup

Clone upstream once, then add the fork as a second remote.

```bash
# clone upstream
git clone https://github.com/OpenCCU/OpenCCU.git openccu
cd openccu

# add fork remote for publishing LTS releases
git remote add ltsfork https://github.com/homematicip/OpenCCU-LTS.git

# optional: verify
git remote -v
```

---

## 7. Workflow A — Land changes on master (Squash & Merge)

1. PR targets: `OpenCCU/OpenCCU:master`
2. Maintainer merges via **Squash & Merge**
3. If the change is LTS-worthy, apply label `backport:LTS` after merge.

**Why Squash helps:** Backporting becomes a single-commit cherry-pick.

---

## 8. Workflow B — Backport a selected PR from master to upstream LTS

Because `master` is squash-merged, each PR corresponds to **one commit** on `master`.

### 8.1 Identify the squash commit SHA

Options:

- From the merged PR page (GitHub UI)
- Locally:

```bash
git fetch origin
git log --oneline origin/master --max-count=80
# find the commit that references the PR number, e.g. "(#1234)"
```

### 8.2 Cherry-pick into a dedicated backport branch (based on upstream LTS)

```bash
git fetch origin

# create a backport branch from upstream LTS
git checkout -b backport/pr-1234-LTS origin/LTS

# cherry-pick the squash commit from master
git cherry-pick -x <SQUASH_SHA>

# push branch to upstream and open a PR into LTS
git push -u origin backport/pr-1234-LTS
```

Then open a PR: `backport/pr-1234-LTS` → `LTS`.

### 8.3 If conflicts occur

```bash
git cherry-pick -x <SQUASH_SHA>

# resolve conflicts
git status
# edit files, then:
git add -A
git cherry-pick --continue
```

### 8.4 Backport PR template (description)

```text
Backport of OpenCCU/OpenCCU#1234 to LTS.

- Source (master squash commit): <SQUASH_SHA>
- Risk: low
- Notes: <tests performed / expected impact>
```

---

## 9. Workflow C — Periodic baseline update of upstream LTS from a master release tag

This is done when you declare a `master` release tag "good enough" to become the next LTS baseline.

### 9.1 Merge the release tag into upstream LTS (no history rewrite)

```bash
git fetch origin --tags

git checkout LTS
git pull origin LTS

# merge the selected master tag into LTS
git merge --no-ff <MASTER_RELEASE_TAG>

# resolve conflicts if any, run tests, then:
git push origin LTS
```

### Notes

- Prefer a real release tag as the baseline anchor.
- Use `--no-ff` so the history clearly shows the baseline merge.

---

## 10. Workflow D — Publish an LTS release from the fork (homematicip/OpenCCU-LTS)

Publishing happens in the fork so that the fork becomes the canonical LTS release channel.

There are two operational models:

### Model D1 (recommended): Fork mirrors upstream `LTS`

- Upstream `OpenCCU/OpenCCU:LTS` is the authoritative LTS branch.
- Fork `homematicip/OpenCCU-LTS:LTS` mirrors upstream `LTS` exactly.
- Releases are created and built in the fork.

This minimizes divergence and makes audits easier.

### 10.1 Sync the fork's `LTS` branch

### Option 1: GitHub UI

- Use "Sync fork" (if available), or open a PR in the fork from upstream to fork.

### Option 2: Git CLI (deterministic, explicit)

```bash
# ensure you have both remotes
git remote -v
# origin   -> OpenCCU/OpenCCU
# ltsfork  -> homematicip/OpenCCU-LTS

# fetch everything
git fetch origin --tags
git fetch ltsfork --tags

# create/update a temporary sync branch from upstream LTS
git checkout -B sync/lts-to-fork origin/LTS

# push that state to the fork's LTS branch
git push ltsfork sync/lts-to-fork:LTS
```

If you want to avoid direct updates to the fork's `LTS` branch, push `sync/lts-to-fork`
as a separate branch and open a PR into `ltsfork:LTS`.

### 10.2 Create the release tag in the fork

Choose the tag name based on your release type:

- Baseline release: `<BASELINE_TAG>` (same as the selected master baseline)
- Maintenance release: same `<MAJOR>.<MINOR>.<PATCH>`, newer `YYYYMMDD`

Create and push the tag:

```bash
# ensure you're releasing from the fork's LTS branch state you want to ship
git checkout LTS
git pull ltsfork LTS

# create an annotated tag
git tag -a 3.85.7.20260215 -m "OpenCCU LTS 3.85.7.20260215"

# push tag to fork
git push ltsfork 3.85.7.20260215
```

### 10.3 Create a GitHub Release in the fork

In GitHub (fork repo):
- Releases → "Draft a new release"
- Select the tag you just pushed
- Title: `OpenCCU LTS <tag>`
- Notes: follow the template below

### 10.4 Ensure CI builds and artifacts are attached

Your release is not "done" until:
- build workflows completed successfully
- all expected platform archives are attached
- checksums (e.g., `.sha256` files) are present

---

## 11. Release notes templates (fork)

### 11.1 Baseline LTS release (new train)

```markdown
## Baseline

This LTS release is based on OpenCCU **<BASELINE_TAG>**.

## Changes vs baseline

No additional changes. This is the baseline for the current LTS period.

## Downloads / Checksums

See the assets attached to this release.
```

### 11.2 Maintenance LTS release (backports)

```markdown
## Baseline

This LTS release is based on OpenCCU **<BASELINE_TAG>**.

## Backported fixes

- OpenCCU/OpenCCU#1234 — <one-line summary>
- OpenCCU/OpenCCU#1250 — <one-line summary>

## Notes

- <upgrade notes / known issues>

## Downloads / Checksums

See the assets attached to this release.
```

---

## 12. Release Captain checklist (detailed)

### 12.1 Scope and readiness

1. Decide: baseline vs maintenance release.
2. Confirm the list of included backports (and that each is approved for LTS).
3. Ensure upstream `LTS` contains exactly what you want to ship.

### 12.2 Sync fork state

1. Sync fork `LTS` to upstream `LTS` (Workflow D, Step 10.1).
2. Verify `git log --oneline` on fork `LTS` matches upstream `LTS` for the release tip.

### 12.3 Tag and release

1. Choose the tag name (policy in Section 4).
2. Create annotated tag and push to the fork (Step 10.2).
3. Draft GitHub release in the fork with correct notes (Section 11).
4. Verify workflows succeeded and all assets + checksums are attached.

### 12.4 Aftercare

1. Announce release (forum/site) with baseline and backport list.
2. If a hotfix is needed, create a new maintenance tag with a newer date.

## Appendix: quick commands

List recent master tags:
```bash
git fetch origin --tags
git tag --list '3.*' --sort=-v:refname | head -n 20
```

Show commits present in master but not in LTS:
```bash
git fetch origin
git log --oneline origin/LTS..origin/master | head
```

Find a merged PR squash commit quickly (by PR number):
```bash
git fetch origin
git log --oneline origin/master | grep -E '\(#1234\)'
```
