FROM ghcr.io/hassio-addons/base:20.1.1

# add docker and ip route stuff
RUN apk add --no-cache docker-cli iproute2 jq

# set workdir to /app
WORKDIR /app

ENV SUPERVISOR_TOKEN ""
VOLUME /config

COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

ARG package_version
# Labels
LABEL \
    org.opencontainers.image.title="OpenCCU HAP/DRAP-Helper-App" \
    org.opencontainers.image.description="OpenCCU Helper App for HmIP-HAP / HmIPW-DRAP connectivity" \
    org.opencontainers.image.vendor="OpenCCU OpenSource Project" \
    org.opencontainers.image.authors="OpenCCU OpenSource Team" \
    org.opencontainers.image.licenses="Apache-2.0" \
    org.opencontainers.image.url="https://openccu.de" \
    org.opencontainers.image.source="https://github.com/OpenCCU/OpenCCU" \
    org.opencontainers.image.documentation="https://github.com/OpenCCU/OpenCCU/wiki" \
    org.opencontainers.image.version=${package_version} \
    io.hass.name="OpenCCU (HAP/DRAP Helper)" \
    io.hass.description="OpenCCU Helper App for HmIP-HAP / HmIPW-DRAP connectivity" \
    io.hass.url=https://github.com/OpenCCU/OpenCCU/tree/master/home-assistant-addon-hapdrap \
    io.hass.arch="aarch64|amd64" \
    io.hass.type="addon" \
    io.hass.version=${package_version}

CMD ["/app/entrypoint.sh"]
