#!/bin/bash

set -e

function resolve_latest_github_stable_tag() {
  local owner=${1}
  local repo=${2}
  local tag

  tag=$(git ls-remote --tags --refs "https://github.com/${owner}/${repo}.git" \
    | awk -F/ '{ print $NF }' \
    | grep -Eiv '(alpha|beta|rc|pre|preview)' \
    | sort -V \
    | tail -n1)

  if [[ -z "${tag}" ]]; then
    echo "failed to resolve latest stable tag for ${owner}/${repo}"
    exit 1
  fi

  echo "${tag}"
}

function strip_v_prefix() {
  local version=${1}
  echo "${version#v}"
}
