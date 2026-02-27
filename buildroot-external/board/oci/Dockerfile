FROM scratch

ARG TARGETARCH
ARG tar_prefix=rootfs

ADD $tar_prefix$TARGETARCH.tar /

LABEL maintainer="OpenCCU OpenSource Team" \
      org.opencontainers.image.title=OpenCCU \
      org.opencontainers.image.description="Alternative OS for your homematicIP CCU" \
      org.opencontainers.image.vendor="OpenCCU OpenSource Project" \
      org.opencontainers.image.authors="OpenCCU OpenSource Team" \
      org.opencontainers.image.licenses="Apache-2.0" \
      org.opencontainers.image.url="https://openccu.de" \
      org.opencontainers.image.source="https://github.com/openccu/openccu" \
      org.opencontainers.image.documentation="https://github.com/openccu/openccu/wiki" \
      io.hass.name="OpenCCU" \
      io.hass.description="HomeMatic/homematicIP OpenCCU central" \
      io.hass.url="https://github.com/openccu/openccu/tree/master/home-assistant-addon" \
      io.hass.type=addon

HEALTHCHECK --interval=60s --timeout=30s --start-period=240s --retries=3 \
  CMD /bin/sh -c 'test -e /var/status/startupFinished || exit 2; test -e /usr/local/HMLGW || /usr/bin/curl --silent -o /dev/null --fail http://localhost/login.htm || exit 1'

STOPSIGNAL SIGTERM

CMD ["/sbin/init"]
EXPOSE 80 22 161 443 1900 1901 1902 5987 1999 2000 2001 2010 8088 8181 9099 9292 9293 10000 41999 42000 42001 42010 43438 43439 48181 48899 49292 49880
