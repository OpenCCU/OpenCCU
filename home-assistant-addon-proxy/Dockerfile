FROM node:22-alpine3.23 AS nodejs

WORKDIR /app

COPY package.json /app/package.json
COPY package-lock.json /app/package-lock.json
RUN npm ci --omit=dev

FROM ghcr.io/hassio-addons/base:20.1.1

# set workdir to /app
WORKDIR /app

VOLUME /config

# Carry the Node.js runtime and its required shared libraries from the builder.
COPY --from=nodejs /usr/local/ /usr/local/
COPY --from=nodejs /usr/lib/libstdc++.so.6 /usr/lib/libstdc++.so.6
COPY --from=nodejs /usr/lib/libgcc_s.so.1 /usr/lib/libgcc_s.so.1
COPY --from=nodejs /app/node_modules /app/node_modules

COPY ha-proxy.js.gtpl /app/ha-proxy.js.gtpl
COPY entrypoint.sh /app/entrypoint.sh
COPY package.json /app/package.json
COPY package-lock.json /app/package-lock.json
RUN chmod +x /app/entrypoint.sh

ARG package_version
# Labels
LABEL \
    org.opencontainers.image.title="OpenCCU HA Proxy-Addon" \
    org.opencontainers.image.description="Proxy to externally running OpenCCU" \
    org.opencontainers.image.vendor="OpenCCU OpenSource Project" \
    org.opencontainers.image.authors="OpenCCU OpenSource Team" \
    org.opencontainers.image.licenses="Apache-2.0" \
    org.opencontainers.image.url="https://openccu.de" \
    org.opencontainers.image.source="https://github.com/OpenCCU/OpenCCU" \
    org.opencontainers.image.documentation="https://github.com/OpenCCU/OpenCCU/wiki" \
    org.opencontainers.image.version=${package_version} \
    io.hass.name="OpenCCU (Proxy)" \
    io.hass.description="Proxy to externally running OpenCCU" \
    io.hass.url=https://github.com/OpenCCU/OpenCCU/tree/master/home-assistant-addon-proxy \
    io.hass.arch="aarch64|amd64" \
    io.hass.type="addon" \
    io.hass.version=${package_version}

HEALTHCHECK --interval=60s --timeout=30s --start-period=30s --retries=3 \
  CMD /bin/sh -c '/usr/bin/curl --silent -o /dev/null http://localhost:8099/ || exit 1'

ENV NODE_PATH=/app/node_modules

CMD ["/app/entrypoint.sh"]
