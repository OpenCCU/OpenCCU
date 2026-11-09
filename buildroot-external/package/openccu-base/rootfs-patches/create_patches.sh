#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'
export LC_ALL=C

((BASH_VERSINFO[0] >= 4)) || {
  printf 'ERROR: Bash 4 or newer is required\n' >&2
  exit 1
}

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)
mode='write'
[[ ${1:-} != --check ]] || mode=check
[[ $# -le 1 ]] || {
  printf 'usage: %s [--check]\n' "${0##*/}" >&2
  exit 2
}

die() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

diff --version 2>/dev/null | grep -q '^diff (GNU diffutils)' || \
  die "GNU diffutils is required"
# An empty series (no rootfs patches left) is valid.
[[ -f ${script_dir}/series ]] || die "missing series file"
temp_dir=$(mktemp -d "${TMPDIR:-/tmp}/openccu-create-patches.XXXXXX")
trap 'rm -rf -- "$temp_dir"' EXIT

declare -A seen=()
failed=0

while IFS= read -r patch_name || [[ -n $patch_name ]]; do
  [[ -n $patch_name && $patch_name != \#* ]] || continue
  [[ $patch_name == [0-9][0-9][0-9][0-9]-*.patch ]] || \
    die "invalid series entry: $patch_name"
  [[ -z ${seen[$patch_name]+x} ]] || die "duplicate series entry: $patch_name"
  seen[$patch_name]=1

  workspace=${script_dir}/${patch_name%.patch}
  workspace_root=${workspace}/rootfs
  output=${temp_dir}/${patch_name}
  [[ -d $workspace_root ]] || die "missing workspace: $workspace_root"

  mapfile -d '' orig_files < <(find "$workspace_root" -type f -name '*.orig' -print0 | sort -z)
  ((${#orig_files[@]} > 0)) || die "workspace has no .orig files: $workspace"

  : >"$output"
  for orig_file in "${orig_files[@]}"; do
    modified_file=${orig_file%.orig}
    [[ -f $modified_file ]] || die "missing modified counterpart: $modified_file"
    relative_path=${orig_file#"${workspace_root}/"}
    relative_path=${relative_path%.orig}

    old_label=a/${relative_path}
    new_label=b/${relative_path}
    if [[ ! -s $orig_file && -s $modified_file ]]; then
      old_label=/dev/null
    elif [[ -s $orig_file && ! -s $modified_file ]]; then
      new_label=/dev/null
    elif [[ ! -s $orig_file && ! -s $modified_file ]]; then
      die "both counterparts are empty: $relative_path in ${patch_name%.patch}"
    fi

    set +e
    diff -u \
      --label="$old_label" \
      --label="$new_label" \
      "$orig_file" "$modified_file" >>"$output"
    diff_status=$?
    set -e
    ((diff_status == 0 || diff_status == 1)) || \
      die "diff failed for $relative_path in ${patch_name%.patch}"
  done

  [[ -s $output ]] || die "generated patch is empty: $patch_name"

  if [[ $mode == check ]]; then
    if ! cmp -s "$output" "${script_dir}/${patch_name}"; then
      printf 'out of date: %s\n' "$patch_name" >&2
      failed=1
    fi
  else
    mv "$output" "${script_dir}/${patch_name}"
  fi
done <"${script_dir}/series"

for patch_file in "${script_dir}"/*.patch; do
  [[ -e $patch_file ]] || continue
  patch_name=${patch_file##*/}
  [[ -n ${seen[$patch_name]+x} ]] || die "patch is not listed in series: $patch_name"
done

exit "$failed"
