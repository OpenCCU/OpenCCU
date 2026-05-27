# ChangeLog

## 0.6.0
- migrate the proxy add-on from the deprecated `base-nodejs` image to the general app-base (`base`) image.
- stage the Node.js runtime and proxy dependencies explicitly and let the app-base init system manage process startup via the add-on `services` startup mode.
- upgrade `http-proxy-middleware` to v4 so the deprecated `util._extend` workaround is no longer necessary on Node.js 22.

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
