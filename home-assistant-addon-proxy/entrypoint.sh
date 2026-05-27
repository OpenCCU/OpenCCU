#!/usr/bin/with-contenv bashio
# shellcheck disable=SC1008
set -euo pipefail

tempio -conf /data/options.json -template /app/ha-proxy.js.gtpl -out /app/ha-proxy.js
exec node /app/ha-proxy.js
