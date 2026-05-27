import http, { IncomingMessage, ServerResponse } from "node:http";
import http2, { Http2ServerRequest, Http2ServerResponse } from "node:http2";
import { EventEmitter } from "node:events";
import net, { Socket } from "node:net";
import * as stream from "node:stream";
import { Duplex } from "node:stream";
interface ProxyTargetDetailed {
  host?: string;
  port?: number | string;
  protocol?: string;
  hostname?: string;
  socketPath?: string;
  key?: string;
  passphrase?: string;
  pfx?: Buffer | string;
  cert?: string;
  ca?: string;
  ciphers?: string;
  secureProtocol?: string;
}
type ProxyTarget = string | URL | ProxyTargetDetailed;
/** Resolved proxy address — either TCP (host + port) or Unix socket. */
type ProxyAddr = {
  host?: string;
  port: number;
  socketPath?: undefined;
} | {
  host?: undefined;
  port?: undefined;
  socketPath: string;
};
interface ProxyServerOptions {
  /** URL string to be parsed. */
  target?: ProxyTarget;
  /** URL string to be parsed. */
  forward?: ProxyTarget;
  /** Object to be passed to http(s).request. */
  agent?: any;
  /** Enable HTTP/2 listener, default is `false` */
  http2?: boolean;
  /** Object to be passed to https.createServer()
   * or http2.createSecureServer() if the `http2` option is enabled
   */
  ssl?: any;
  /** If you want to proxy websockets. */
  ws?: boolean;
  /** Adds x- forward headers. */
  xfwd?: boolean;
  /** Verify SSL certificate. */
  secure?: boolean;
  /** Explicitly specify if we are proxying to another proxy. */
  toProxy?: boolean;
  /** Specify whether you want to prepend the target's path to the proxy path. */
  prependPath?: boolean;
  /** Specify whether you want to ignore the proxy path of the incoming request. */
  ignorePath?: boolean;
  /** Local interface string to bind for outgoing connections. */
  localAddress?: string;
  /** Changes the origin of the host header to the target URL. */
  changeOrigin?: boolean;
  /** specify whether you want to keep letter case of response header key */
  preserveHeaderKeyCase?: boolean;
  /** Basic authentication i.e. 'user:password' to compute an Authorization header. */
  auth?: string;
  /** Rewrites the location hostname on (301 / 302 / 307 / 308) redirects, Default: null. */
  hostRewrite?: string;
  /** Rewrites the location host/ port on (301 / 302 / 307 / 308) redirects based on requested host/ port.Default: false. */
  autoRewrite?: boolean;
  /** Rewrites the location protocol on (301 / 302 / 307 / 308) redirects to 'http' or 'https'.Default: null. */
  protocolRewrite?: string;
  /** Rewrites domain of set-cookie headers. */
  cookieDomainRewrite?: false | string | {
    [oldDomain: string]: string;
  };
  /** Rewrites path of set-cookie headers. Default: false */
  cookiePathRewrite?: false | string | {
    [oldPath: string]: string;
  };
  /** Object with extra headers to be added to target requests. */
  headers?: {
    [header: string]: string;
  };
  /** Timeout (in milliseconds) when proxy receives no response from target. Default: 120000 (2 minutes) */
  proxyTimeout?: number;
  /** Timeout (in milliseconds) for incoming requests */
  timeout?: number;
  /** If set to true, none of the webOutgoing passes are called and it's your responsibility to appropriately return the response by listening and acting on the proxyRes event */
  selfHandleResponse?: boolean;
  /** Follow HTTP redirects from target. `true` = max 5 hops; number = custom max. */
  followRedirects?: boolean | number;
  /** Buffer */
  buffer?: stream.Stream;
}
type ResOfType<T extends "web" | "ws"> = T extends "ws" ? T extends "web" ? ServerResponse | Http2ServerResponse | Socket : Socket : T extends "web" ? ServerResponse | Http2ServerResponse : never;
type ProxyMiddleware<T extends ServerResponse | Http2ServerResponse | Socket> = (req: IncomingMessage | Http2ServerRequest, res: T, opts: ProxyServerOptions & {
  target: URL | ProxyTargetDetailed;
  forward: URL;
}, server: ProxyServer<IncomingMessage | Http2ServerRequest, ServerResponse | Http2ServerResponse>, head?: Buffer, callback?: (err: any, req: IncomingMessage | Http2ServerRequest, socket: T, url?: any) => void) => void | true;
interface ProxyServerEventMap<Req extends http.IncomingMessage | http2.Http2ServerRequest = http.IncomingMessage, Res extends http.ServerResponse | http2.Http2ServerResponse = http.ServerResponse> {
  error: [err: Error, req?: Req, res?: Res | net.Socket, target?: URL | ProxyTarget];
  start: [req: Req, res: Res, target: URL | ProxyTarget];
  econnreset: [err: Error, req: Req, res: Res, target: URL | ProxyTarget];
  proxyReq: [proxyReq: http.ClientRequest, req: Req, res: Res, options: ProxyServerOptions];
  proxyReqWs: [proxyReq: http.ClientRequest, req: Req, socket: net.Socket, options: ProxyServerOptions, head: any];
  proxyRes: [proxyRes: http.IncomingMessage, req: Req, res: Res];
  end: [req: Req, res: Res, proxyRes: http.IncomingMessage];
  open: [proxySocket: net.Socket];
  /** @deprecated */
  proxySocket: [proxySocket: net.Socket];
  close: [proxyRes: Req, proxySocket: net.Socket, proxyHead: any];
}
declare class ProxyServer<Req extends http.IncomingMessage | http2.Http2ServerRequest = http.IncomingMessage, Res extends http.ServerResponse | http2.Http2ServerResponse = http.ServerResponse> extends EventEmitter<ProxyServerEventMap<Req, Res>> {
  private _server?;
  _webPasses: ProxyMiddleware<http.ServerResponse>[];
  _wsPasses: ProxyMiddleware<net.Socket>[];
  options: ProxyServerOptions;
  web: (req: Req, res: Res, opts?: ProxyServerOptions, head?: any) => Promise<void>;
  ws: (req: Req, socket: net.Socket, opts: ProxyServerOptions, head?: any) => Promise<void>;
  /**
   * Creates the proxy server with specified options.
   * @param options - Config object passed to the proxy
   */
  constructor(options?: ProxyServerOptions);
  /**
   * A function that wraps the object in a webserver, for your convenience
   * @param port - Port to listen on
   * @param hostname - The hostname to listen on
   * @param listeningListener - A callback function that is called when the server starts listening
   */
  listen(port: number, hostname?: string, listeningListener?: () => void): this;
  /**
   * A function that closes the inner webserver and stops listening on given port
   */
  close(callback?: () => void): void;
  before<Type extends "ws" | "web">(type: Type, passName: string, pass: ProxyMiddleware<ResOfType<Type>>): void;
  after<Type extends "ws" | "web">(type: Type, passName: string, pass: ProxyMiddleware<ResOfType<Type>>): void;
  /** @internal */
  _getPasses<Type extends "ws" | "web">(type: Type): ProxyMiddleware<ResOfType<Type>>[];
}
/**
 * Creates the proxy server.
 *
 * Examples:
 *
 *    httpProxy.createProxyServer({ .. }, 8000)
 *    // => '{ web: [Function], ws: [Function] ... }'
 *
 * @param {Object} Options Config object passed to the proxy
 *
 * @return {Object} Proxy Proxy object with handlers for `ws` and `web` requests
 *
 * @api public
 */
declare function createProxyServer(options?: ProxyServerOptions): ProxyServer<http.IncomingMessage, http.ServerResponse>;
/**
 * Options for {@link proxyFetch}.
 */
interface ProxyFetchOptions {
  /**
   * Timeout in milliseconds for the upstream request.
   * Rejects with an error if the upstream does not respond within this time.
   */
  timeout?: number;
  /**
   * Add `x-forwarded-for`, `x-forwarded-port`, `x-forwarded-proto`, and
   * `x-forwarded-host` headers derived from the input URL.
   * Default: `false`.
   */
  xfwd?: boolean;
  /**
   * Rewrite the `Host` header to match the target address.
   * Default: `false` (original host from the input URL is kept).
   */
  changeOrigin?: boolean;
  /**
   * HTTP agent for connection pooling / reuse.
   * Default: `false` (no agent, no keep-alive).
   */
  agent?: any;
  /**
   * Follow HTTP redirects from the upstream.
   * `true` = max 5 hops; number = custom max.
   * Default: `false` (manual redirect, raw 3xx responses are returned).
   */
  followRedirects?: boolean | number;
  /**
   * TLS options forwarded to `https.request` (e.g. `{ rejectUnauthorized: false }`).
   * Also controls certificate verification — set `rejectUnauthorized: false` to skip.
   * Default: none.
   */
  ssl?: Record<string, unknown>;
}
/**
 * Proxy a request to a specific server address (TCP host/port or Unix socket)
 * using web standard {@link Request}/{@link Response} interfaces.
 *
 * Supports both HTTP and HTTPS upstream targets.
 *
 * @param addr - The target server address. Can be a URL string (`http://host:port`, `https://host:port`, `unix:/path`), or an object with `host`/`port` for TCP or `socketPath` for Unix sockets.
 * @param input - The request URL (string or URL) or a {@link Request} object.
 * @param inputInit - Optional {@link RequestInit} or {@link Request} to override method, headers, and body.
 * @param opts - Optional proxy options.
 */
declare function proxyFetch(addr: string | ProxyAddr, input: string | URL | Request, inputInit?: RequestInit | Request, opts?: ProxyFetchOptions): Promise<Response>;
/**
 * Options for {@link proxyUpgrade}.
 */
interface ProxyUpgradeOptions {
  /**
   * Add `x-forwarded-for`, `x-forwarded-port`, and `x-forwarded-proto` headers.
   * Default: `true`.
   */
  xfwd?: boolean;
  /**
   * Rewrite the `Host` header to match the target.
   * Default: `false` (original host is kept).
   */
  changeOrigin?: boolean;
  /**
   * Extra headers to include in the upstream upgrade request.
   * Default: none.
   */
  headers?: Record<string, string>;
  /**
   * TLS options forwarded to `https.request`.
   * Default: none.
   */
  ssl?: Record<string, unknown>;
  /**
   * Whether to verify upstream TLS certificates.
   * Default: `true`.
   */
  secure?: boolean;
  /**
   * HTTP/HTTPS agent used for the upstream request.
   * Default: `false` (no keep-alive agent is used).
   */
  agent?: any;
  /**
   * Local interface address to bind for upstream connections.
   * Default: OS-selected local address.
   */
  localAddress?: string;
  /**
   * Basic auth credentials in `username:password` format.
   * Default: none.
   */
  auth?: string;
  /**
   * Prepend the target path to the proxied request path.
   * Default: `true`.
   */
  prependPath?: boolean;
  /**
   * Ignore the incoming request path when building the upstream path.
   * Default: `false` (incoming path is used).
   */
  ignorePath?: boolean;
  /**
   * Send absolute URL in request path when proxying to another proxy.
   * Default: `false` (path-only request target is used).
   */
  toProxy?: boolean;
}
/**
 * Proxy a WebSocket upgrade request to a target address without creating a
 * {@link ProxyServer} instance. Similar to {@link proxyFetch} but for
 * WebSocket upgrades.
 *
 * @param addr - Target server address. Can be a URL string (`http://host:port`, `ws://host:port`, `unix:/path`), or an object with `host`/`port` for TCP or `socketPath` for Unix sockets.
 * @param req - The incoming HTTP upgrade request.
 * @param socket - The network socket between the server and client.
 * @param head - The first packet of the upgraded stream (may be empty).
 * @param opts - Optional proxy options.
 * @returns A promise that resolves with the upstream proxy socket once the
 * WebSocket connection is established, or rejects on error.
 */
declare function proxyUpgrade(addr: string | ProxyAddr, req: IncomingMessage, socket: Duplex, head?: Buffer, opts?: ProxyUpgradeOptions): Promise<Socket>;
export { type ProxyAddr, type ProxyFetchOptions, ProxyServer, type ProxyServerEventMap, type ProxyServerOptions, type ProxyTarget, type ProxyTargetDetailed, type ProxyUpgradeOptions, createProxyServer, proxyFetch, proxyUpgrade };