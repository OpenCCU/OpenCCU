#!/bin/bash

# Stop on error
set -e

#BOARD_DIR="$(dirname "$0")"
#BOARD_NAME="$(basename "${BOARD_DIR}")"

# make sure a factory reset is performed upon fresh start
touch "${TARGET_DIR}/usr/local/.doFactoryReset"
