#!/bin/bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd -P)
REPO_ROOT=$(cd "${SCRIPT_DIR}/.." && pwd -P)
DEST_DIR="${REPO_ROOT}/buildroot-external/overlay/WebUI-openccu/www/webui/js/extern/codemirror6"
VERSION_FILE="${DEST_DIR}/VERSION"
ENTRY_FILE="${REPO_ROOT}/scripts/codemirror6/entry.js"
CSS_FILE="${REPO_ROOT}/scripts/codemirror6/codemirror6.css"

CURRENT_VERSION=$(sed -nE 's/^CODEMIRROR6_VERSION = (.*)$/\1/p' "${VERSION_FILE}" 2>/dev/null | head -n1 || true)
NEW_VERSION=$(npm view codemirror version)

if [[ -n "${CURRENT_VERSION}" && "${CURRENT_VERSION}" == "${NEW_VERSION}" ]]; then
  echo "codemirror6: version ${NEW_VERSION} is already current, no update required"
  exit 0
fi

TMP_DIR=$(mktemp -d)
trap 'rm -rf -- "${TMP_DIR}"' EXIT

pushd "${TMP_DIR}" >/dev/null
npm init -y >/dev/null
npm install --silent --no-package-lock \
  codemirror@"${NEW_VERSION}" \
  @codemirror/autocomplete@latest \
  @codemirror/commands@latest \
  @codemirror/language@latest \
  @codemirror/legacy-modes@latest \
  @codemirror/search@latest \
  @codemirror/state@latest \
  @codemirror/view@latest \
  esbuild@latest >/dev/null

cp -f "${ENTRY_FILE}" "${TMP_DIR}/entry.js"
npx esbuild "${TMP_DIR}/entry.js" \
  --bundle \
  --format=iife \
  --platform=browser \
  --target=es2018 \
  --minify \
  --outfile="${TMP_DIR}/codemirror6.bundle.js" \
  --log-level=error

mkdir -p "${DEST_DIR}"
cp -f "${TMP_DIR}/codemirror6.bundle.js" "${DEST_DIR}/codemirror6.bundle.js"
cp -f "${CSS_FILE}" "${DEST_DIR}/codemirror6.bundle.css"

{
  echo "CODEMIRROR6_VERSION = ${NEW_VERSION}"
  echo "BUNDLED_AT = $(date -u +%Y-%m-%dT%H:%M:%SZ)"
} >"${VERSION_FILE}"

popd >/dev/null

echo "codemirror6: updated to ${NEW_VERSION}"
