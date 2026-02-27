FROM ghcr.io/hassio-addons/base-nodejs:0.2.5

# set workdir to /app
WORKDIR /app

ENV SUPERVISOR_TOKEN ""
VOLUME /config

COPY ha-proxy.js.gtpl /app/ha-proxy.js.gtpl
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

ARG package_version
# Labels
LABEL \
    org.opencontainers.image.title="OpenCCU HA Proxy-Addon" \
    org.opencontainers.image.description="Proxy to externally running OpenCCU" \
    org.opencontainers.image.vendor="OpenCCU OpenSource Project" \
    org.opencontainers.image.authors="OpenCCU OpenSource Team" \
    org.opencontainers.image.licenses="Apache-2.0" \
    org.opencontainers.image.url="https://raspberrymatic.de" \
    org.opencontainers.image.source="https://github.com/OpenCCU/OpenCCU" \
    org.opencontainers.image.documentation="https://github.com/OpenCCU/OpenCCU/wiki" \
    org.opencontainers.image.version=${package_version} \
    io.hass.name="OpenCCU (Proxy)" \
    io.hass.description="Proxy to externally running OpenCCU" \
    io.hass.url=https://github.com/OpenCCU/OpenCCU/tree/master/home-assistant-addon-proxy \
    io.hass.arch="armv7|aarch64|amd64" \
    io.hass.type="addon" \
    io.hass.version=${package_version}

HEALTHCHECK --interval=60s --timeout=30s --start-period=30s --retries=3 \
  CMD /bin/sh -c '/usr/bin/curl --silent -o /dev/null http://localhost:8099/ || exit 1'

# Install express + http-proxy-middleware packages for
# ha-proxy.js
ENV NODE_PATH=/app/node_modules
RUN npm install express
RUN npm install http-proxy-middleware

ENTRYPOINT ["/app/entrypoint.sh"]
