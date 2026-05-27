# ChangeLog

## 0.5.3
- migrate the proxy add-on from the deprecated `base-nodejs` image to `app-base`.
- install Node.js and npm explicitly and let the app-base init system manage process startup.

## 0.5.2
- pin Node.js dependencies to keep `http-proxy-middleware` on CommonJS-compatible v3 releases.
- add direct dependency declarations and reproducible npm lockfile for stable proxy app builds.

## 0.4.3
- add healthcheck for better addon watchdog support
- add debug output when starting ha-proxy.
- minor fixes

## 0.3.0
- initial release

For a recent ChangeLog please review the following information:

- [OpenCCU Releases](https://github.com/OpenCCU/OpenCCU/releases)
