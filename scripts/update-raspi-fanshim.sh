#!/bin/bash
set -e
set -o pipefail

if [ -z "$1" ]; then
  echo "Need a raspi-fanshim tag/commit id (see https://github.com/flobernd/raspi-fanshim)"
  exit 1
fi

sed -i "s/RASPI_FANSHIM_VERSION = .*/RASPI_FANSHIM_VERSION = $1/g" buildroot-external/package/raspi-fanshim/raspi-fanshim.mk
