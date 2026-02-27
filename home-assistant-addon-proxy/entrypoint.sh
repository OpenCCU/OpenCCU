#!/bin/sh
tempio -conf /data/options.json -template /app/ha-proxy.js.gtpl -out /app/ha-proxy.js
chmod a+rx /app/ha-proxy.js
exec /app/ha-proxy.js
