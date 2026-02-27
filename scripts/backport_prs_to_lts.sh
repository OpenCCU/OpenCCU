#!/usr/bin/env bash
set -euo pipefail

# backport_prs_to_lts.sh
#
# Create a fresh batch backport PR into the LTS branch.
#
# Input modes:
#   A) Provide PR numbers explicitly:
#        ./backport_prs_to_lts.sh 1234 1250 1301
#   B) Provide a GitHub search query (PRs will be selected from master, merged, with required labels):
#        ./backport_prs_to_lts.sh --search 'merged:>=2025-12-01'
#
# Required labels (must BOTH be present):
#   - backport:LTS
#   - backport-risk:low
#
# "Already backported" detection (without a backported label):
#   - If the PR's mergeCommit SHA is an ancestor of LTS: already included (baseline merge case)
#   - If LTS commit messages contain that SHA (from `git cherry-pick -x`): already backported
#   - Best-effort fallback: look for "(#PR)" in LTS commit messages
#
# Requirements:
#   - git
#   - GitHub CLI: gh (authenticated)
#
# Optional env vars:
#   REPO="OpenCCU/OpenCCU"        (default)
#   MASTER_BRANCH="master"        (default)
#   LTS_BRANCH="LTS"              (default)
#   PUSH_REMOTE="origin"          (default)
#   LIMIT=200                     (default for --search)
#
# Options:
#   --verbose          Print detailed reasoning (e.g., why something was skipped)
#   --dry-run          Print actions, do not change anything
#
# Post-run convenience:
#   - Prints a PR->backport-commit mapping (per cherry-picked commit SHA) that can be used for later reverts.
#     This mapping is most useful if you MERGE (merge-commit) the batch PR into LTS (not squash),
#     because individual commits remain revertable.

REPO="${REPO:-OpenCCU/OpenCCU}"
MASTER_BRANCH="${MASTER_BRANCH:-master}"
LTS_BRANCH="${LTS_BRANCH:-LTS}"
PUSH_REMOTE="${PUSH_REMOTE:-origin}"
LIMIT="${LIMIT:-200}"

LABEL_A="backport:LTS"
LABEL_B="backport-risk:low"

SEARCH_QUERY=""
DRY_RUN="false"
VERBOSE="false"

usage() {
  cat <<EOF
Usage:
  $0 <PR_NUMBER> [PR_NUMBER ...]
  $0 --search '<GITHUB_SEARCH_QUERY>' [--dry-run] [--verbose]

Options:
  --search <query>   GitHub search query (e.g., 'merged:>=2025-12-01 sort:updated-desc')
                     The script still enforces:
                       - state: merged
                       - base:  $MASTER_BRANCH
                       - labels: '$LABEL_A' AND '$LABEL_B'
  --dry-run          Show what would be done, but do not cherry-pick/push/create PR.
  --verbose          Print detailed reasoning (e.g., why a PR is considered "already in LTS").
  -h, --help         Show this help.

Examples:
  $0 1234 1250 1301
  $0 --search 'merged:>=2025-12-01' --dry-run --verbose
  REPO=OpenCCU/OpenCCU $0 --search 'author:jp112sdl merged:>=2025-11-01'

EOF
}

logv() {
  if [[ "$VERBOSE" == "true" ]]; then
    echo "VERBOSE: $*"
  fi
}

# --- argument parsing ---
ARGS=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --search)
      shift
      [[ $# -gt 0 ]] || { echo "ERROR: --search requires a value"; exit 2; }
      SEARCH_QUERY="$1"
      shift
      ;;
    --dry-run)
      DRY_RUN="true"
      shift
      ;;
    --verbose|-v)
      VERBOSE="true"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      ARGS+=("$1")
      shift
      ;;
  esac
done

# Validate mode
if [[ -z "$SEARCH_QUERY" && ${#ARGS[@]} -lt 1 ]]; then
  echo "ERROR: Provide PR numbers or use --search."
  usage
  exit 2
fi
if [[ -n "$SEARCH_QUERY" && ${#ARGS[@]} -gt 0 ]]; then
  echo "ERROR: Use either PR numbers OR --search, not both."
  usage
  exit 2
fi

# Ensure tools exist
command -v gh >/dev/null 2>&1 || { echo "ERROR: 'gh' not found. Install GitHub CLI."; exit 2; }
command -v git >/dev/null 2>&1 || { echo "ERROR: 'git' not found."; exit 2; }

# Ensure in git repo
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || { echo "ERROR: Not inside a git working tree."; exit 2; }

# Refuse dirty tree
if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "ERROR: Working tree has uncommitted changes. Commit/stash first."
  exit 2
fi

BRANCH="backport/batch-lts-$(date +%Y%m%d-%H%M%S)"

# IMPORTANT: Use mktemp templates that already include the file extension.
TMP_ALL="$(mktemp -t lts-backport-all.XXXXXX.tsv)"
TMP_TODO="$(mktemp -t lts-backport-todo.XXXXXX.tsv)"
TMP_SKIP="$(mktemp -t lts-backport-skip.XXXXXX.tsv)"
TMP_BODY="$(mktemp -t lts-backport-body.XXXXXX.md)"
TMP_MAP="$(mktemp -t lts-backport-map.XXXXXX.tsv)"

# Defensive: ensure files exist and are empty
: > "$TMP_ALL"
: > "$TMP_TODO"
: > "$TMP_SKIP"
: > "$TMP_BODY"
: > "$TMP_MAP"

cleanup() {
  rm -f "$TMP_ALL" "$TMP_TODO" "$TMP_SKIP" "$TMP_BODY" "$TMP_MAP"
}
trap cleanup EXIT

count_lines() {
  [[ -f "$1" ]] && wc -l < "$1" | tr -d ' ' || echo 0
}

# Fetch refs for LTS checks
git fetch "$PUSH_REMOTE" >/dev/null 2>&1 || true
git fetch origin >/dev/null 2>&1 || true

# Determine an LTS ref to inspect (prefer PUSH_REMOTE, else origin)
LTS_REF=""
if git show-ref --verify --quiet "refs/remotes/$PUSH_REMOTE/$LTS_BRANCH"; then
  LTS_REF="$PUSH_REMOTE/$LTS_BRANCH"
elif git show-ref --verify --quiet "refs/remotes/origin/$LTS_BRANCH"; then
  LTS_REF="origin/$LTS_BRANCH"
else
  echo "ERROR: Could not find remote ref for '$LTS_BRANCH' on '$PUSH_REMOTE' or 'origin'."
  exit 1
fi
logv "Using LTS ref for presence checks: $LTS_REF"

# --- Step 1: Build candidate list (PRNUM  SHA  TITLE  URL  MERGEDAT) ---

if [[ -n "$SEARCH_QUERY" ]]; then
  echo "Collecting PRs via search query from $REPO..."
  echo "Search: $SEARCH_QUERY"
  gh pr list -R "$REPO" \
    --state merged \
    --base "$MASTER_BRANCH" \
    --label "$LABEL_A" \
    --label "$LABEL_B" \
    --limit "$LIMIT" \
    --search "$SEARCH_QUERY" \
    --json number,title,url,mergedAt,mergeCommit \
    --jq 'sort_by(.mergedAt)[] | select(.mergeCommit.oid != null) | [.number, .mergeCommit.oid, .title, .url, .mergedAt] | @tsv' \
    > "$TMP_ALL"

  if [[ ! -s "$TMP_ALL" ]]; then
    echo "No matching PRs found."
    exit 0
  fi
else
  echo "Validating explicit PR numbers in $REPO..."
  for pr in "${ARGS[@]}"; do
    [[ "$pr" =~ ^[0-9]+$ ]] || { echo "ERROR: '$pr' is not numeric."; exit 2; }

    labels_ok="$(gh pr view "$pr" -R "$REPO" --json labels --jq \
      "(.labels | map(.name) | (index(\"$LABEL_A\") != null) and (index(\"$LABEL_B\") != null))" 2>/dev/null || echo "false")"
    [[ "$labels_ok" == "true" ]] || {
      echo "ERROR: PR #$pr does not have required labels '$LABEL_A' AND '$LABEL_B'."
      exit 1
    }

    sha="$(gh pr view "$pr" -R "$REPO" --json mergeCommit --jq '.mergeCommit.oid' 2>/dev/null || true)"
    [[ -n "${sha:-}" && "$sha" != "null" ]] || {
      echo "ERROR: PR #$pr has no merge commit SHA (not merged, or mergeCommit unavailable)."
      exit 1
    }

    title="$(gh pr view "$pr" -R "$REPO" --json title --jq '.title' 2>/dev/null || echo "")"
    url="$(gh pr view "$pr" -R "$REPO" --json url --jq '.url' 2>/dev/null || echo "")"
    mergedAt="$(gh pr view "$pr" -R "$REPO" --json mergedAt --jq '.mergedAt' 2>/dev/null || echo "")"

    printf "%s\t%s\t%s\t%s\t%s\n" "$pr" "$sha" "$title" "$url" "$mergedAt" >> "$TMP_ALL"
  done
fi

# --- Step 2: Filter out PRs already included in LTS ---

echo "Checking which PRs are already present in $LTS_REF..."

while IFS=$'\t' read -r pr sha title url mergedAt; do
  already="false"
  reason=""

  # (1) Ancestor check: if SHA is already reachable from LTS tip.
  if git merge-base --is-ancestor "$sha" "$LTS_REF" >/dev/null 2>&1; then
    already="true"
    reason="ancestor-of-LTS (baseline merge or identical commit exists)"
  else
    # (2) Commit message provenance: `cherry-pick -x` usually embeds the original SHA.
    # IMPORTANT: git log returns exit code 0 even if nothing matched; therefore we must test OUTPUT.
    hit_sha="$(git log "$LTS_REF" --grep="$sha" -n 1 --format='%H' 2>/dev/null || true)"
    if [[ -n "$hit_sha" ]]; then
      already="true"
      reason="commit-message-mentions-sha (likely cherry-pick -x; matched commit $hit_sha)"
    else
      # (3) Best-effort fallback: look for "(#PR)" in commit messages
      hit_pr="$(git log "$LTS_REF" --grep="\\(#${pr}\\)" -n 1 --format='%H' 2>/dev/null || true)"
      if [[ -n "$hit_pr" ]]; then
        already="true"
        reason="commit-message-mentions-pr-number (matched commit $hit_pr)"
      fi
    fi
  fi

  if [[ "$already" == "true" ]]; then
    logv "SKIP  #$pr ($sha): $reason"
    printf "%s\t%s\t%s\t%s\t%s\n" "$pr" "$sha" "$title" "$url" "$mergedAt" >> "$TMP_SKIP"
  else
    logv "TODO  #$pr ($sha): not found in LTS"
    printf "%s\t%s\t%s\t%s\t%s\n" "$pr" "$sha" "$title" "$url" "$mergedAt" >> "$TMP_TODO"
  fi
done < "$TMP_ALL"

echo "Candidates: $(count_lines "$TMP_ALL")"
echo "To backport: $(count_lines "$TMP_TODO")"
echo "Skipped (already in LTS): $(count_lines "$TMP_SKIP")"

if [[ ! -s "$TMP_TODO" ]]; then
  echo "Nothing to backport."
  exit 0
fi

echo
echo "Backport list (PR -> source SHA):"
awk -F'\t' '{printf "  #%s -> %s\n", $1, $2}' "$TMP_TODO"
echo

if [[ "$DRY_RUN" == "true" ]]; then
  echo "Dry-run enabled. Exiting without changes."
  exit 0
fi

# --- Step 3: Create backport branch from LTS tip ---

echo "Creating backport branch '$BRANCH' from '$LTS_REF'..."
git checkout -B "$BRANCH" "$LTS_REF"

# --- Step 4: Cherry-pick the mergeCommit SHAs and record backport commit SHAs ---

echo "Cherry-picking commits into '$BRANCH'..."
while IFS=$'\t' read -r pr sha title url mergedAt; do
  echo "  - PR #$pr: $sha — $title"

  # Record current HEAD to compute the new commit produced by cherry-pick.
  before="$(git rev-parse HEAD)"

  if ! git cherry-pick -x "$sha"; then
    echo
    echo "ERROR: Conflict while cherry-picking PR #$pr ($sha)."
    echo "Resolve conflicts, then run:"
    echo "  git add -A"
    echo "  git cherry-pick --continue"
    echo "Or abort with:"
    echo "  git cherry-pick --abort"
    exit 1
  fi

  after="$(git rev-parse HEAD)"
  if [[ "$after" == "$before" ]]; then
    echo "ERROR: Unexpected: HEAD did not change after cherry-pick of $sha."
    exit 1
  fi

  # Save mapping: PRNUM  BACKPORT_COMMIT_SHA  SOURCE_SHA  TITLE
  printf "%s\t%s\t%s\t%s\n" "$pr" "$after" "$sha" "$title" >> "$TMP_MAP"
  logv "Mapped PR #$pr to backport commit $after (from source $sha)"
done < "$TMP_TODO"

# --- Step 5: Generate PR body ---

{
  echo "Batch backport into \`$LTS_BRANCH\`."
  echo
  echo "Selection criteria:"
  echo "- Base branch: \`$MASTER_BRANCH\`"
  echo "- Required labels: \`$LABEL_A\`, \`$LABEL_B\`"
  echo
  echo "Included PRs:"
  echo
  while IFS=$'\t' read -r pr sha title url mergedAt; do
    echo "- #$pr — $title ($url)"
  done < "$TMP_TODO"
  echo
  if [[ -s "$TMP_SKIP" ]]; then
    echo "Skipped (already present in LTS):"
    echo
    while IFS=$'\t' read -r pr sha title url mergedAt; do
      echo "- #$pr — $title ($url)"
    done < "$TMP_SKIP"
    echo
  fi
  echo "Notes:"
  echo "- Applied via \`git cherry-pick -x\` to preserve provenance."
  echo "- 'Already present' detection uses ancestry and commit-message provenance."
} > "$TMP_BODY"

# --- Step 6: Push branch and open PR ---

echo "Pushing branch to '$PUSH_REMOTE'..."
git push -u "$PUSH_REMOTE" "$BRANCH"

TITLE="Backport to $LTS_BRANCH (batch $(date +%Y-%m-%d))"

echo "Creating PR against '$LTS_BRANCH' in '$REPO'..."
gh pr create -R "$REPO" \
  --base "$LTS_BRANCH" \
  --head "$BRANCH" \
  --title "$TITLE" \
  --body-file "$TMP_BODY"

# --- Step 7: Print PR->backport commit mapping for later reverts ---

echo
echo "Backport commit mapping (useful for later reverts if you MERGE this PR into LTS):"
echo "  PR   BACKPORT_COMMIT_SHA                             SOURCE_SHA                                   TITLE"
echo "  ---- ----------------------------------------------- ------------------------------------------- ----------------------------------------"
while IFS=$'\t' read -r pr backport_sha source_sha title; do
  printf "  #%-4s %-47s %-43s %s\n" "$pr" "$backport_sha" "$source_sha" "$title"
done < "$TMP_MAP"

echo
echo "Tip: After the PR is merged into '$LTS_BRANCH' with a MERGE COMMIT (not squash),"
echo "you can revert a single backport via:"
echo "  git checkout $LTS_BRANCH && git pull"
echo "  git revert <BACKPORT_COMMIT_SHA>"
echo "  git push"
echo
echo "Done."
