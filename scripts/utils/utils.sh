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

  tag=$(python3 - "${owner}" "${repo}" "${tag_filter_pattern}" <<'PY'
import re
import sys
import urllib.request
import urllib.error
import json
import xml.etree.ElementTree as ET

owner, repo, tag_filter_pattern = sys.argv[1:]
api_url = f"https://api.github.com/repos/{owner}/{repo}/releases"
feed_url = f"https://github.com/{owner}/{repo}/releases.atom"
tag_regex = re.compile(tag_filter_pattern)
ns = {"atom": "http://www.w3.org/2005/Atom"}
headers = {
    "Accept": "application/vnd.github+json",
    "Accept-Language": "en-US,en;q=0.5",
    "User-Agent": "OpenCCU-dependency-updater",
}

try:
    page = 1
    while True:
        request = urllib.request.Request(
            f"{api_url}?per_page=100&page={page}",
            headers=headers,
        )
        with urllib.request.urlopen(request) as response:
            releases = json.load(response)
        if not releases:
            break
        for release in releases:
            tag = release.get("tag_name", "")
            if release.get("draft") or release.get("prerelease"):
                continue
            if not tag_regex.fullmatch(tag):
                continue
            print(tag)
            sys.exit(0)
        page += 1
except (urllib.error.URLError, json.JSONDecodeError, ET.ParseError):
    print(f"GitHub API lookup failed for {owner}/{repo}, falling back to release pages", file=sys.stderr)

try:
    with urllib.request.urlopen(urllib.request.Request(feed_url, headers=headers)) as response:
        root = ET.fromstring(response.read())

    for entry in root.findall("atom:entry", ns):
        link = entry.find("atom:link", ns)
        if link is None:
            continue

        release_url = link.attrib.get("href", "")
        tag = release_url.rsplit("/", 1)[-1]
        if not tag_regex.fullmatch(tag):
            continue

        with urllib.request.urlopen(urllib.request.Request(release_url, headers=headers)) as response:
            html = response.read().decode("utf-8", errors="ignore")
        # The Atom feed omits prerelease/draft flags, so the rendered release label is the fallback signal.
        if ">Pre-release<" in html or ">Draft<" in html:
            continue

        print(tag)
        sys.exit(0)
except (urllib.error.URLError, ET.ParseError):
    print(f"GitHub release page fallback failed for {owner}/{repo}", file=sys.stderr)
PY
)

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
