#!/usr/bin/env bash
# Refresh every .orig/modified pair from a newly generated pristine rootfs.
# Existing generated patches carry the intended deltas and are applied in
# series order. Nothing in the committed workspaces is replaced until the
# complete seed series has applied successfully.

set -Eeuo pipefail
IFS=$'\n\t'
export LC_ALL=C

((BASH_VERSINFO[0] >= 4)) || {
  printf 'ERROR: Bash 4 or newer is required\n' >&2
  exit 1
}

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)

die() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

copy_or_empty() {
  local source=$1
  local destination=$2
  mkdir -p "$(dirname "$destination")"
  if [[ -e $source || -L $source ]]; then
    cp -a "$source" "$destination"
  else
    : >"$destination"
  fi
}

replace_numeric_highlights() {
  local javascript_file=$1
  local device_type=$2
  local desired_file output_file
  desired_file=$(mktemp "${TMPDIR:-/tmp}/openccu-highlights.XXXXXX")
  output_file=$(mktemp "${javascript_file}.XXXXXX")
  cat >"$desired_file"

  if ! awk -v device_type="$device_type" -v desired_file="$desired_file" '
    function highlight_key(line) {
      sub(/^DEV_HIGHLIGHT\[[^]]*\]\[/, "", line)
      sub(/\].*$/, "", line)
      return line
    }
    BEGIN {
      target = "DEV_HIGHLIGHT[\"" device_type "\"] = new Object();"
      while ((getline desired_line < desired_file) > 0) {
        desired[++desired_count] = desired_line
        desired_keys[highlight_key(desired_line)] = 1
      }
      close(desired_file)
    }
    $0 == target {
      print
      for (line_number = 1; line_number <= desired_count; line_number++) {
        print desired[line_number]
      }
      found = 1
      inside_device = 1
      next
    }
    # Replace only the channels listed above; keep other channels from Base.
    inside_device && $0 ~ ("^DEV_HIGHLIGHT\\[\"" device_type "\"\\]\\[\"[0-9]+\"\\]") &&
        highlight_key($0) in desired_keys {
      next
    }
    inside_device && /^DEV_LIST\.push/ {
      inside_device = 0
    }
    { print }
    END {
      if (!found) {
        exit 42
      }
    }
  ' "$javascript_file" >"$output_file"; then
    rm -f -- "$desired_file" "$output_file"
    die "device block not found while rebasing 0125: $device_type"
  fi

  chmod --reference="$javascript_file" "$output_file"
  mv "$output_file" "$javascript_file"
  rm -f -- "$desired_file"
}

apply_channel_highlights_semantically() {
  local javascript_file=$1

  replace_numeric_highlights "$javascript_file" HmIPW-DRS8 <<'HIGHLIGHTS_HMIPW_DRS8'
DEV_HIGHLIGHT["HmIPW-DRS8"]["1"]   = [1, 0.208, 0.080, 0.050];
DEV_HIGHLIGHT["HmIPW-DRS8"]["2"]   = [1, 0.208, 0.080, 0.050];
DEV_HIGHLIGHT["HmIPW-DRS8"]["3"]   = [1, 0.208, 0.080, 0.050];
DEV_HIGHLIGHT["HmIPW-DRS8"]["4"]   = [1, 0.208, 0.080, 0.050];
DEV_HIGHLIGHT["HmIPW-DRS8"]["5"]   = [1, 0.422, 0.075, 0.050];
DEV_HIGHLIGHT["HmIPW-DRS8"]["6"]   = [1, 0.422, 0.075, 0.050];
DEV_HIGHLIGHT["HmIPW-DRS8"]["7"]   = [1, 0.422, 0.075, 0.050];
DEV_HIGHLIGHT["HmIPW-DRS8"]["8"]   = [1, 0.422, 0.075, 0.050];
DEV_HIGHLIGHT["HmIPW-DRS8"]["9"]   = [1, 0.636, 0.070, 0.050];
DEV_HIGHLIGHT["HmIPW-DRS8"]["10"]  = [1, 0.636, 0.070, 0.050];
DEV_HIGHLIGHT["HmIPW-DRS8"]["11"]  = [1, 0.636, 0.070, 0.050];
DEV_HIGHLIGHT["HmIPW-DRS8"]["12"]  = [1, 0.636, 0.070, 0.050];
DEV_HIGHLIGHT["HmIPW-DRS8"]["13"]  = [1, 0.205, 0.910, 0.040];
DEV_HIGHLIGHT["HmIPW-DRS8"]["14"]  = [1, 0.205, 0.910, 0.040];
DEV_HIGHLIGHT["HmIPW-DRS8"]["15"]  = [1, 0.205, 0.910, 0.040];
DEV_HIGHLIGHT["HmIPW-DRS8"]["16"]  = [1, 0.205, 0.910, 0.040];
DEV_HIGHLIGHT["HmIPW-DRS8"]["17"]  = [1, 0.425, 0.910, 0.040];
DEV_HIGHLIGHT["HmIPW-DRS8"]["18"]  = [1, 0.425, 0.910, 0.040];
DEV_HIGHLIGHT["HmIPW-DRS8"]["19"]  = [1, 0.425, 0.910, 0.040];
DEV_HIGHLIGHT["HmIPW-DRS8"]["20"]  = [1, 0.425, 0.910, 0.040];
DEV_HIGHLIGHT["HmIPW-DRS8"]["21"]  = [1, 0.645, 0.900, 0.040];
DEV_HIGHLIGHT["HmIPW-DRS8"]["22"]  = [1, 0.645, 0.900, 0.040];
DEV_HIGHLIGHT["HmIPW-DRS8"]["23"]  = [1, 0.645, 0.900, 0.040];
DEV_HIGHLIGHT["HmIPW-DRS8"]["24"]  = [1, 0.645, 0.900, 0.040];
DEV_HIGHLIGHT["HmIPW-DRS8"]["25"]  = [1, 0.275, 0.242, 0.050];
DEV_HIGHLIGHT["HmIPW-DRS8"]["26"]  = [1, 0.275, 0.242, 0.050];
DEV_HIGHLIGHT["HmIPW-DRS8"]["27"]  = [1, 0.275, 0.242, 0.050];
DEV_HIGHLIGHT["HmIPW-DRS8"]["28"]  = [1, 0.275, 0.242, 0.050];
DEV_HIGHLIGHT["HmIPW-DRS8"]["29"]  = [1, 0.485, 0.230, 0.050];
DEV_HIGHLIGHT["HmIPW-DRS8"]["30"]  = [1, 0.485, 0.230, 0.050];
DEV_HIGHLIGHT["HmIPW-DRS8"]["31"]  = [1, 0.485, 0.230, 0.050];
DEV_HIGHLIGHT["HmIPW-DRS8"]["32"]  = [1, 0.485, 0.230, 0.050];
HIGHLIGHTS_HMIPW_DRS8

  replace_numeric_highlights "$javascript_file" HmIP-WRC6 <<'HIGHLIGHTS_HMIP_WRC6'
DEV_HIGHLIGHT["HmIP-WRC6"]["1"] = [1, 0.270, 0.310, 0.050];
DEV_HIGHLIGHT["HmIP-WRC6"]["2"] = [1, 0.675, 0.285, 0.050];
DEV_HIGHLIGHT["HmIP-WRC6"]["3"] = [1, 0.270, 0.510, 0.050];
DEV_HIGHLIGHT["HmIP-WRC6"]["4"] = [1, 0.675, 0.480, 0.050];
DEV_HIGHLIGHT["HmIP-WRC6"]["5"] = [1, 0.270, 0.706, 0.050];
DEV_HIGHLIGHT["HmIP-WRC6"]["6"] = [1, 0.675, 0.671, 0.050];
HIGHLIGHTS_HMIP_WRC6

  replace_numeric_highlights "$javascript_file" HmIPW-WRC6 <<'HIGHLIGHTS_HMIPW_WRC6'
DEV_HIGHLIGHT["HmIPW-WRC6"]["1"]  = [1, 0.270, 0.310, 0.050];
DEV_HIGHLIGHT["HmIPW-WRC6"]["2"]  = [1, 0.675, 0.285, 0.050];
DEV_HIGHLIGHT["HmIPW-WRC6"]["3"]  = [1, 0.270, 0.510, 0.050];
DEV_HIGHLIGHT["HmIPW-WRC6"]["4"]  = [1, 0.675, 0.480, 0.050];
DEV_HIGHLIGHT["HmIPW-WRC6"]["5"]  = [1, 0.270, 0.706, 0.050];
DEV_HIGHLIGHT["HmIPW-WRC6"]["6"]  = [1, 0.675, 0.671, 0.050];
DEV_HIGHLIGHT["HmIPW-WRC6"]["7"]  = [1, 0.270, 0.310, 0.050];
DEV_HIGHLIGHT["HmIPW-WRC6"]["8"]  = [1, 0.675, 0.285, 0.050];
DEV_HIGHLIGHT["HmIPW-WRC6"]["9"]  = [1, 0.270, 0.510, 0.050];
DEV_HIGHLIGHT["HmIPW-WRC6"]["10"] = [1, 0.675, 0.480, 0.050];
DEV_HIGHLIGHT["HmIPW-WRC6"]["11"] = [1, 0.270, 0.706, 0.050];
DEV_HIGHLIGHT["HmIPW-WRC6"]["12"] = [1, 0.675, 0.671, 0.050];
HIGHLIGHTS_HMIPW_WRC6

  replace_numeric_highlights "$javascript_file" HmIP-BSL <<'HIGHLIGHTS_HMIP_BSL'
DEV_HIGHLIGHT["HmIP-BSL"]["1"]  = [1, 0.505, 0.635, 0.050];
DEV_HIGHLIGHT["HmIP-BSL"]["2"]  = [1, 0.505, 0.360, 0.050];
DEV_HIGHLIGHT["HmIP-BSL"]["8"]  = [1, 0.505, 0.360, 0.050];
DEV_HIGHLIGHT["HmIP-BSL"]["9"]  = [1, 0.505, 0.360, 0.050];
DEV_HIGHLIGHT["HmIP-BSL"]["10"] = [1, 0.505, 0.360, 0.050];
DEV_HIGHLIGHT["HmIP-BSL"]["12"] = [1, 0.505, 0.635, 0.050];
DEV_HIGHLIGHT["HmIP-BSL"]["13"] = [1, 0.505, 0.635, 0.050];
DEV_HIGHLIGHT["HmIP-BSL"]["14"] = [1, 0.505, 0.635, 0.050];
HIGHLIGHTS_HMIP_BSL

  replace_numeric_highlights "$javascript_file" HmIPW-DRAP <<'HIGHLIGHTS_HMIPW_DRAP'
DEV_HIGHLIGHT["HmIPW-DRAP"]["1"] = [1, 0.240, 0.875, 0.040];
DEV_HIGHLIGHT["HmIPW-DRAP"]["2"] = [1, 0.450, 0.875, 0.040];
HIGHLIGHTS_HMIPW_DRAP

  replace_numeric_highlights "$javascript_file" HmIPW-DRS4 <<'HIGHLIGHTS_HMIPW_DRS4'
DEV_HIGHLIGHT["HmIPW-DRS4"]["1"] = [1, 0.217, 0.090, 0.040];
DEV_HIGHLIGHT["HmIPW-DRS4"]["2"] = [1, 0.217, 0.090, 0.040];
DEV_HIGHLIGHT["HmIPW-DRS4"]["3"] = [1, 0.217, 0.090, 0.040];
DEV_HIGHLIGHT["HmIPW-DRS4"]["4"] = [1, 0.217, 0.090, 0.040];
DEV_HIGHLIGHT["HmIPW-DRS4"]["5"] = [1, 0.650, 0.075, 0.040];
DEV_HIGHLIGHT["HmIPW-DRS4"]["6"] = [1, 0.650, 0.075, 0.040];
DEV_HIGHLIGHT["HmIPW-DRS4"]["7"] = [1, 0.650, 0.075, 0.040];
DEV_HIGHLIGHT["HmIPW-DRS4"]["8"] = [1, 0.650, 0.075, 0.040];
DEV_HIGHLIGHT["HmIPW-DRS4"]["9"] = [1, 0.210, 0.910, 0.040];
DEV_HIGHLIGHT["HmIPW-DRS4"]["10"] = [1, 0.210, 0.910, 0.040];
DEV_HIGHLIGHT["HmIPW-DRS4"]["11"] = [1, 0.210, 0.910, 0.040];
DEV_HIGHLIGHT["HmIPW-DRS4"]["12"] = [1, 0.210, 0.910, 0.040];
DEV_HIGHLIGHT["HmIPW-DRS4"]["13"] = [1, 0.645, 0.900, 0.040];
DEV_HIGHLIGHT["HmIPW-DRS4"]["14"] = [1, 0.645, 0.900, 0.040];
DEV_HIGHLIGHT["HmIPW-DRS4"]["15"] = [1, 0.645, 0.900, 0.040];
DEV_HIGHLIGHT["HmIPW-DRS4"]["16"] = [1, 0.645, 0.900, 0.040];
HIGHLIGHTS_HMIPW_DRS4
}

apply_hmip_rfusb_webui_semantically() {
  local javascript_file=$1
  local output_file
  local has_device=0
  local has_known_type=0

  grep -q "^DEV_LIST.push('HmIP-RFUSB');$" "$javascript_file" && has_device=1
  grep -Eq '^    "HmIP-RFUSB",?$' "$javascript_file" && has_known_type=1
  output_file=$(mktemp "${javascript_file}.XXXXXX")

  if ! awk -v has_device="$has_device" -v has_known_type="$has_known_type" '
    BEGIN { single_quote = sprintf("%c", 39) }
    $0 == "DEV_HIGHLIGHT[\"RPI-RF-MOD\"] = new Object();" && !has_device {
      print
      print "DEV_LIST.push(" single_quote "HmIP-RFUSB" single_quote ");"
      print "DEV_DESCRIPTION[\"HmIP-RFUSB\"] = \"HmIP-RFUSB\";"
      print "DEV_PATHS[\"HmIP-RFUSB\"] = new Object();"
      print "DEV_PATHS[\"HmIP-RFUSB\"][\"50\"] = \"/config/img/devices/50/CCU3_thumb.png\";"
      print "DEV_PATHS[\"HmIP-RFUSB\"][\"250\"] = \"/config/img/devices/250/CCU3.png\";"
      print "DEV_HIGHLIGHT[\"HmIP-RFUSB\"] = new Object();"
      inserted_device = 1
      next
    }
    $0 == "    \"RPI-RF-MOD\"" && !has_known_type {
      print "    \"RPI-RF-MOD\","
      print "    \"HmIP-RFUSB\""
      inserted_known_type = 1
      next
    }
    { print }
    END {
      if ((!has_device && !inserted_device) ||
          (!has_known_type && !inserted_known_type)) {
        exit 42
      }
    }
  ' "$javascript_file" >"$output_file"; then
    rm -f -- "$output_file"
    die "cannot locate the RPI-RF-MOD anchors while rebasing 0155"
  fi

  chmod --reference="$javascript_file" "$output_file"
  mv "$output_file" "$javascript_file"
}

apply_hmip_rfusb_semantically() {
  local patch_file=$1
  local state=$2
  local non_webui_patch
  non_webui_patch=$(mktemp "${TMPDIR:-/tmp}/openccu-0155-without-webui.XXXXXX")

  awk '
    /^--- a\/www\/webui\/webui\.js$/ { skip_webui = 1 }
    !skip_webui { print }
  ' "$patch_file" >"$non_webui_patch"

  if [[ ! -s $non_webui_patch ]]; then
    rm -f -- "$non_webui_patch"
    die "failed to isolate the non-WebUI portion of 0155"
  fi

  if ! patch -s -t -d "$state" -p1 -F0 -N <"$non_webui_patch"; then
    rm -f -- "$non_webui_patch"
    die "cannot rebase the non-webui.js portion of 0155"
  fi
  rm -f -- "$non_webui_patch"

  apply_hmip_rfusb_webui_semantically "${state}/www/webui/webui.js"
}

apply_rega_escape_semantically() {
  local rega_file=$1
  local output_file
  output_file=$(mktemp "${rega_file}.XXXXXX")

  if ! awk '
    FNR == NR {
      probe = $0
      sub(/\r$/, "", probe)
      if (probe == "    \"\\\\\"  \"\\\\\\\\\"") {
        mapping_exists = 1
      }
      next
    }
    {
      line = $0
      carriage_return = ""
      if (sub(/\r$/, "", line)) {
        carriage_return = "\r"
      }

      print line carriage_return
      if (line == "proc rega_escape {value} {") {
        inside_rega_escape = 1
      } else if (inside_rega_escape && line == "  return [string map {") {
        if (!mapping_exists) {
          print "    \"\\\\\"  \"\\\\\\\\\"" carriage_return
          inserted_mapping = 1
        }
        inside_rega_escape = 0
      }
    }
    END {
      if (!mapping_exists && !inserted_mapping) {
        exit 42
      }
    }
  ' "$rega_file" "$rega_file" >"$output_file"; then
    rm -f -- "$output_file"
    die "cannot locate rega_escape while rebasing 0207"
  fi

  chmod --reference="$rega_file" "$output_file"
  mv "$output_file" "$rega_file"
}

apply_rega_injection_fix_semantically() {
  local patch_file=$1
  local state=$2
  local non_rega_patch
  non_rega_patch=$(mktemp "${TMPDIR:-/tmp}/openccu-0207-without-rega.XXXXXX")

  awk '
    /^--- a\/www\/tcl\/eq3\/rega\.tcl$/ { skip_rega = 1 }
    !skip_rega { print }
  ' "$patch_file" >"$non_rega_patch"

  if [[ ! -s $non_rega_patch ]]; then
    rm -f -- "$non_rega_patch"
    die "failed to isolate the non-rega.tcl portion of 0207"
  fi

  if ! patch -s -t -d "$state" -p1 -F0 -N <"$non_rega_patch"; then
    rm -f -- "$non_rega_patch"
    die "cannot rebase the non-rega.tcl portion of 0207"
  fi
  rm -f -- "$non_rega_patch"

  apply_rega_escape_semantically "${state}/www/tcl/eq3/rega.tcl"
}

[[ $# == 1 || $# == 2 ]] || \
  die "usage: ${0##*/} PRISTINE_ROOTFS [OPENCCU_BASE_SOURCE]"
patch --version 2>/dev/null | grep -q '^GNU patch ' || \
  die "GNU patch is required"
diff --version 2>/dev/null | grep -q '^diff (GNU diffutils)' || \
  die "GNU diffutils is required"
chmod --version 2>/dev/null | grep -q '^chmod (GNU coreutils)' || \
  die "GNU coreutils is required"
pristine_rootfs=$(cd "$1" && pwd -P)
if (($# == 2)); then
  openccu_base_source=$(cd "$2" && pwd -P)
else
  openccu_base_source=$(cd "${pristine_rootfs}/../.." && pwd -P)
fi
[[ -s ${script_dir}/series ]] || die "missing series file"

temp_dir=$(mktemp -d "${TMPDIR:-/tmp}/openccu-update-patchfiles.XXXXXX")
trap 'rm -rf -- "$temp_dir"' EXIT
state=${temp_dir}/rootfs
new_workspaces=${temp_dir}/workspaces
mkdir -p "$state" "$new_workspaces"
cp -a "${pristine_rootfs}/." "$state/"
"${script_dir}/prepare_patch_input.sh" "$state" "$openccu_base_source"

while IFS= read -r patch_name || [[ -n $patch_name ]]; do
  [[ -n $patch_name && $patch_name != \#* ]] || continue
  patch_file=${script_dir}/${patch_name}
  workspace_name=${patch_name%.patch}
  output_root=${new_workspaces}/${workspace_name}/rootfs
  [[ -s $patch_file ]] || die "missing patch from series: $patch_name"

  mapfile -t paths < <(
    awk '
      /^--- (a\/|\/dev\/null)/ { old_path=$2 }
      /^\+\+\+ (b\/|\/dev\/null)/ {
        new_path=$2
        if (new_path != "/dev/null") {
          sub(/^b\//, "", new_path)
          print new_path
        } else {
          sub(/^a\//, "", old_path)
          print old_path
        }
      }
    ' "$patch_file" | sort -u
  )
  ((${#paths[@]} > 0)) || die "patch has no usable file headers: $patch_name"

  for relative_path in "${paths[@]}"; do
    [[ $relative_path != /* && $relative_path != *'../'* && $relative_path != '..' ]] || \
      die "unsafe patch path in $patch_name: $relative_path"
    copy_or_empty "${state}/${relative_path}" \
      "${output_root}/${relative_path}.orig"
  done

  case $patch_name in
    0125-WebUI-ChannelHighlights.patch)
      apply_channel_highlights_semantically "${state}/www/webui/webui.js"
      ;;
    0155-WebUI-Add-HmIP-RFUSB-Support.patch)
      apply_hmip_rfusb_semantically "$patch_file" "$state"
      ;;
    0207-WebUI-Fix-ReGaScriptInjection.patch)
      apply_rega_injection_fix_semantically "$patch_file" "$state"
      ;;
    *)
      patch -s -t -d "$state" -p1 -F0 -N <"$patch_file" || \
        die "cannot rebase $patch_name onto the supplied pristine rootfs"
      ;;
  esac

  for relative_path in "${paths[@]}"; do
    copy_or_empty "${state}/${relative_path}" \
      "${output_root}/${relative_path}"
  done
done <"${script_dir}/series"

# The whole seed series applied. Replace only the rootfs/occu payload inside
# each workspace; patch-specific README files and other metadata are retained.
while IFS= read -r patch_name || [[ -n $patch_name ]]; do
  [[ -n $patch_name && $patch_name != \#* ]] || continue
  workspace_name=${patch_name%.patch}
  workspace=${script_dir}/${workspace_name}
  staged_root=${new_workspaces}/${workspace_name}/rootfs
  [[ -d $workspace && -d $staged_root ]] || die "workspace mismatch: $workspace_name"
  rm -rf -- "${workspace}/rootfs" "${workspace}/occu"
  mv "$staged_root" "${workspace}/rootfs"
done <"${script_dir}/series"

"${script_dir}/create_patches.sh"
"${script_dir}/validate_patches.sh" "$pristine_rootfs" "$openccu_base_source"
