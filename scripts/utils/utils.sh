#!/bin/bash

set -e
set -o pipefail

function resolve_latest_github_stable_tag() {
  local owner=${1}
  local repo=${2}
  local tag_filter_pattern=${3:-'^[vV]?[0-9]+(\.[0-9]+)*$'}
  local tag

  tag=$(git ls-remote --tags --refs "https://github.com/${owner}/${repo}.git" \
    | awk -F/ '{ print $NF }' \
    | grep -E "${tag_filter_pattern}" \
    | grep -Eiv '(alpha|beta|rc|pre|preview)' \
    | sort -V \
    | tail -n1)

  if [[ -z "${tag}" ]]; then
    echo "Failed to resolve latest stable tag for ${owner}/${repo} (pattern: ${tag_filter_pattern})" >&2
    exit 1
  fi

  echo "${tag}"
}

function resolve_latest_github_stable_release_tag() {
  local owner=${1}
  local repo=${2}
  local tag_filter_pattern=${3:-'^[vV]?[0-9]+(\.[0-9]+)*$'}
  local tag

  tag=$(wget --quiet -O - "https://api.github.com/repos/${owner}/${repo}/releases?per_page=100" \
    | python3 -c 'import json, sys; releases = json.load(sys.stdin); print("\n".join(release["tag_name"] for release in releases if not release.get("draft") and not release.get("prerelease") and release.get("tag_name")))' \
    | grep -E "${tag_filter_pattern}" \
    | grep -Eiv '(alpha|beta|rc|pre|preview)' \
    | sort -V \
    | tail -n1)

  if [[ -z "${tag}" ]]; then
    echo "Failed to resolve latest stable release tag for ${owner}/${repo} (pattern: ${tag_filter_pattern})" >&2
    exit 1
  fi

  echo "${tag}"
}

function strip_v_prefix() {
  local version=${1}
  echo "${version#v}"
}

function resolve_latest_github_head_commit() {
  local owner=${1}
  local repo=${2}
  local commit

  commit=$(git ls-remote "https://github.com/${owner}/${repo}.git" HEAD | awk '{ print $1 }')

  if [[ -z "${commit}" ]]; then
    echo "Failed to resolve latest HEAD commit for ${owner}/${repo}" >&2
    exit 1
  fi

  echo "${commit}"
}

function resolve_latest_github_head_commit_for_path() {
  local owner=${1}
  local repo=${2}
  local path=${3}
  local commit

  commit=$(wget --quiet -O - "https://api.github.com/repos/${owner}/${repo}/commits?path=${path}&per_page=1" \
    | grep -m1 '"sha"' \
    | sed -E 's/.*"sha": "([^"]+)".*/\1/')

  if [[ -z "${commit}" ]]; then
    echo "Failed to resolve latest commit for path ${path} in ${owner}/${repo}" >&2
    exit 1
  fi

  echo "${commit}"
}

function exit_if_version_unchanged() {
  local current_version=${1}
  local resolved_version=${2}
  local component_name=${3}

  if [[ -n "${current_version}" && "${current_version}" == "${resolved_version}" ]]; then
    echo "${component_name}: version ${resolved_version} is already current, skipping archive download and hash update"
    exit 0
  fi
}
