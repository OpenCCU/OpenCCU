#!/bin/bash
# shellcheck source=/dev/null
set -e
set -o pipefail

echo "scripts/update-occu.sh is deprecated; forwarding to scripts/update-openccu-base.sh" >&2
exec "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/update-openccu-base.sh" "$@"
