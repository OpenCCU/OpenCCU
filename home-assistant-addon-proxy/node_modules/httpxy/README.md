# 🔀 httpxy

[![npm version][npm-version-src]][npm-version-href]
[![npm downloads][npm-downloads-src]][npm-downloads-href]
[![bundle][bundle-src]][bundle-href]
[![Codecov][codecov-src]][codecov-href]

A Full-Featured HTTP and WebSocket Proxy for Node.js

## Proxy Fetch

`proxyFetch` is a proxy utility with web standard (`Request`/`Response`) interfaces. It forwards requests to a specific server address (TCP host/port or Unix socket), bypassing the URL's hostname.

```ts
import { proxyFetch } from "httpxy";

// TCP — using a URL string
const res = await proxyFetch("http://127.0.0.1:3000", "http://example.com/api/data");
console.log(await res.json());

// Unix socket — using a URL string
const res2 = await proxyFetch("unix:/tmp/app.sock", "http://localhost/health");
console.log(await res2.text());

// Or use an object for more control
const res3 = await proxyFetch({ host: "127.0.0.1", port: 3000 }, "http://example.com/api/data");

// Using a Request object
const req = new Request("http://example.com/api/data", {
  method: "POST",
  headers: { "Content-Type": "application/json" },
  body: JSON.stringify({ key: "value" }),
});
const res4 = await proxyFetch("http://127.0.0.1:3000", req);

// Using a URL string with RequestInit
const res5 = await proxyFetch("http://127.0.0.1:3000", "http://example.com/api/data", {
  method: "PUT",
  headers: { Authorization: "Bearer token" },
  body: JSON.stringify({ updated: true }),
});
```

It accepts the same `input` and `init` arguments as the global `fetch`, including `Request` objects and streaming bodies, and returns a standard `Response`. Redirects are handled manually by default.

## Proxy Upgrade

`proxyUpgrade` is a standalone WebSocket upgrade proxy. It forwards `upgrade` requests to a target server without needing a `ProxyServer` instance — the WebSocket counterpart to `proxyFetch`.

```ts
import { createServer } from "node:http";
import { proxyUpgrade } from "httpxy";

const server = createServer((req, res) => {
  // Handle regular HTTP requests...
});

server.on("upgrade", (req, socket, head) => {
  proxyUpgrade("http://127.0.0.1:8080", req, socket, head);
});

server.listen(3000);
```

It accepts the same `addr` formats as `proxyFetch` (`"http://host:port"`, `"unix:/path"`, or `{ host, port }` / `{ socketPath }`), and returns a `Promise<Socket>` that resolves with the upstream proxy socket once the WebSocket connection is established.

```ts
// With options
server.on("upgrade", (req, socket, head) => {
  proxyUpgrade({ host: "127.0.0.1", port: 8080 }, req, socket, head, {
    // changeOrigin: true, // rewrite Host header
    // xfwd: false, // disable x-forwarded-* headers (enabled by default)
  });
});
```

## Proxy Server

> [!NOTE]
> Proxy server was originally forked from [http-party/node-http-proxy](https://github.com/http-party/node-http-proxy).

Create proxy:

```ts
import { createServer } from "node:http";
import { createProxyServer } from "httpxy";

const proxy = createProxyServer({});

const server = createServer(async (req, res) => {
  try {
    await proxy.web(req, res, {
      target: address /* address of your proxy server here */,
    });
  } catch (error) {
    console.error(error);
    res.statusCode = 500;
    res.end("Proxy error: " + error.toString());
  }
});

server.listen(3000, () => {
  console.log("Proxy is listening on http://localhost:3000");
});
```

## Options

| Option                  | Type                                   | Default    | Description                                                                 |
| ----------------------- | -------------------------------------- | ---------- | --------------------------------------------------------------------------- |
| `target`                | `string \| URL \| ProxyTargetDetailed` | —          | Target server URL                                                           |
| `forward`               | `string \| URL`                        | —          | Forward server URL (pipes request without the target's response)            |
| `agent`                 | `http.Agent \| false`                  | keep-alive | Shared keep-alive agent by default. Set `false` to disable connection reuse |
| `ssl`                   | `https.ServerOptions`                  | —          | Object passed to `https.createServer()`                                     |
| `ws`                    | `boolean`                              | `false`    | Enable WebSocket proxying                                                   |
| `xfwd`                  | `boolean`                              | `false`    | Add `x-forwarded-*` headers                                                 |
| `secure`                | `boolean`                              | —          | Verify SSL certificates                                                     |
| `toProxy`               | `boolean`                              | `false`    | Pass absolute URL as path (proxy-to-proxy)                                  |
| `prependPath`           | `boolean`                              | `true`     | Prepend the target's path to the proxy path                                 |
| `ignorePath`            | `boolean`                              | `false`    | Ignore the incoming request path                                            |
| `localAddress`          | `string`                               | —          | Local interface to bind for outgoing connections                            |
| `changeOrigin`          | `boolean`                              | `false`    | Change the `Host` header to match the target URL                            |
| `preserveHeaderKeyCase` | `boolean`                              | `false`    | Keep original letter case of response header keys                           |
| `auth`                  | `string`                               | —          | Basic authentication (`'user:password'`) for `Authorization` header         |
| `hostRewrite`           | `string`                               | —          | Rewrite the `Location` hostname on redirects (301/302/307/308)              |
| `autoRewrite`           | `boolean`                              | `false`    | Rewrite `Location` host/port on redirects based on the request              |
| `protocolRewrite`       | `string`                               | —          | Rewrite `Location` protocol on redirects (`'http'` or `'https'`)            |
| `cookieDomainRewrite`   | `false \| string \| object`            | `false`    | Rewrite domain of `Set-Cookie` headers                                      |
| `cookiePathRewrite`     | `false \| string \| object`            | `false`    | Rewrite path of `Set-Cookie` headers                                        |
| `headers`               | `object`                               | —          | Extra headers to add to target requests                                     |
| `proxyTimeout`          | `number`                               | `120000`   | Timeout (ms) for the proxy request to the target                            |
| `timeout`               | `number`                               | —          | Timeout (ms) for the incoming request                                       |
| `selfHandleResponse`    | `boolean`                              | `false`    | Disable automatic response piping (handle `proxyRes` yourself)              |
| `followRedirects`       | `boolean \| number`                    | `false`    | Follow HTTP redirects from target. `true` = max 5 hops; number = custom max |
| `buffer`                | `stream.Stream`                        | —          | Stream to use as request body instead of the incoming request               |

## Events

| Event        | Arguments                                | Description                                            |
| ------------ | ---------------------------------------- | ------------------------------------------------------ |
| `error`      | `(err, req, res, target)`                | An error occurred during proxying                      |
| `proxyReq`   | `(proxyReq, req, res, options)`          | Before request is sent to target (modify headers here) |
| `proxyRes`   | `(proxyRes, req, res)`                   | Response received from target                          |
| `proxyReqWs` | `(proxyReq, req, socket, options, head)` | Before WebSocket upgrade request is sent               |
| `open`       | `(proxySocket)`                          | WebSocket connection opened                            |
| `close`      | `(proxyRes, proxySocket, proxyHead)`     | WebSocket connection closed                            |
| `start`      | `(req, res, target)`                     | Proxy processing started                               |
| `end`        | `(req, res, proxyRes)`                   | Proxy request completed                                |

## Examples

### HTTP Proxy

```ts
import { createServer } from "node:http";
import { createProxyServer } from "httpxy";

const proxy = createProxyServer({});

const server = createServer(async (req, res) => {
  await proxy.web(req, res, { target: "http://localhost:8080" });
});

server.listen(3000);
```

### WebSocket Proxy

```ts
import { createServer } from "node:http";
import { createProxyServer } from "httpxy";

const proxy = createProxyServer({ target: "http://localhost:8080", ws: true });

const server = createServer(async (req, res) => {
  await proxy.web(req, res);
});

server.on("upgrade", (req, socket, head) => {
  proxy.ws(req, socket, { target: "http://localhost:8080" }, head);
});

server.listen(3000);
```

### Modify Request Headers

```ts
import { createServer } from "node:http";
import { createProxyServer } from "httpxy";

const proxy = createProxyServer({ target: "http://localhost:8080" });

proxy.on("proxyReq", (proxyReq) => {
  proxyReq.setHeader("X-Forwarded-By", "httpxy");
});

const server = createServer(async (req, res) => {
  await proxy.web(req, res);
});

server.listen(3000);
```

### HTTPS Proxy

```ts
import { readFileSync } from "node:fs";
import { createProxyServer } from "httpxy";

const proxy = createProxyServer({
  ssl: {
    key: readFileSync("server-key.pem", "utf8"),
    cert: readFileSync("server-cert.pem", "utf8"),
  },
  target: "https://localhost:8443",
  secure: false, // allow self-signed certificates
});

proxy.listen(3000);
```

### Standalone Proxy Server

```ts
import { createProxyServer } from "httpxy";

const proxy = createProxyServer({
  target: "http://localhost:8080",
  changeOrigin: true,
});

proxy.listen(3000);
```

## Development

- Clone this repository
- Install latest LTS version of [Node.js](https://nodejs.org/en/)
- Enable [Corepack](https://github.com/nodejs/corepack) using `corepack enable`
- Install dependencies using `pnpm install`
- Run interactive tests using `pnpm dev`

## Acknowledgements

Performance optimizations in httpxy were inspired by analysis of [fast-proxy](https://github.com/fastify/fast-proxy) and [@fastify/http-proxy](https://github.com/fastify/fastify-http-proxy).

## License

Made with 💛

Published under [MIT License](./LICENSE).

<!-- Badges -->

[npm-version-src]: https://img.shields.io/npm/v/httpxy?style=flat&colorA=18181B&colorB=F0DB4F
[npm-version-href]: https://npmjs.com/package/httpxy
[npm-downloads-src]: https://img.shields.io/npm/dm/httpxy?style=flat&colorA=18181B&colorB=F0DB4F
[npm-downloads-href]: https://npmjs.com/package/httpxy
[codecov-src]: https://img.shields.io/codecov/c/gh/unjs/httpxy/main?style=flat&colorA=18181B&colorB=F0DB4F
[codecov-href]: https://codecov.io/gh/unjs/httpxy
[bundle-src]: https://img.shields.io/bundlephobia/minzip/httpxy?style=flat&colorA=18181B&colorB=F0DB4F
[bundle-href]: https://bundlephobia.com/result?p=httpxy
