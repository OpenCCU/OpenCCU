import http, { request } from "node:http";
import https, { request as request$1 } from "node:https";
import http2 from "node:http2";
import { EventEmitter } from "node:events";
import "node:net";
import { Readable } from "node:stream";
const upgradeHeader = /(^|,)\s*upgrade\s*($|,)/i;
const defaultAgents = {
	http: new http.Agent({
		keepAlive: true,
		maxSockets: 256,
		maxFreeSockets: 64
	}),
	https: new https.Agent({
		keepAlive: true,
		maxSockets: 256,
		maxFreeSockets: 64
	})
};
const isSSL = /^https|wss/;
const HTTP2_HEADER_BLACKLIST = [
	":method",
	":path",
	":scheme",
	":authority"
];
function setupOutgoing(outgoing, options, req, forward) {
	outgoing.port = options[forward || "target"].port || (isSSL.test(options[forward || "target"].protocol ?? "http") ? 443 : 80);
	for (const e of [
		"host",
		"hostname",
		"socketPath",
		"pfx",
		"key",
		"passphrase",
		"cert",
		"ca",
		"ciphers",
		"secureProtocol"
	]) {
		const value = options[forward || "target"][e];
		if (value !== void 0) outgoing[e] = value;
	}
	if (outgoing.host === void 0 && typeof outgoing.hostname === "string") {
		const bracketedHost = outgoing.hostname.includes(":") && !outgoing.hostname.startsWith("[") ? `[${outgoing.hostname}]` : outgoing.hostname;
		outgoing.host = outgoing.port ? `${bracketedHost}:${outgoing.port}` : bracketedHost;
	}
	outgoing.method = options.method || req.method;
	outgoing.headers = { ...req.headers };
	if (req.headers?.[":authority"]) outgoing.headers.host = req.headers[":authority"];
	if (options.headers) for (const key of Object.keys(options.headers)) outgoing.headers[key] = options.headers[key];
	if (req.httpVersionMajor > 1) for (const header of HTTP2_HEADER_BLACKLIST) delete outgoing.headers[header];
	if (options.auth) outgoing.auth = options.auth;
	if (options.ca) outgoing.ca = options.ca;
	if (isSSL.test(options[forward || "target"].protocol ?? "http")) outgoing.rejectUnauthorized = options.secure === void 0 ? true : options.secure;
	if (options.agent !== void 0) outgoing.agent = options.agent || false;
	else if (req.httpVersionMajor > 1 || upgradeHeader.test(req.headers.connection || "")) outgoing.agent = false;
	else {
		const targetProto = options[forward || "target"].protocol ?? "http";
		outgoing.agent = isSSL.test(targetProto) ? defaultAgents.https : defaultAgents.http;
	}
	outgoing.localAddress = options.localAddress;
	if (!outgoing.agent) {
		outgoing.headers = outgoing.headers || {};
		if (typeof outgoing.headers.connection !== "string" || !upgradeHeader.test(outgoing.headers.connection)) outgoing.headers.connection = "close";
	}
	const target = options[forward || "target"];
	const targetPath = target && options.prependPath !== false ? target.pathname || "" : "";
	const targetSearch = target instanceof URL && options.prependPath !== false ? target.search || "" : "";
	const reqUrl = req.url || "";
	const qIdx = reqUrl.indexOf("?");
	const reqPath = qIdx === -1 ? reqUrl : reqUrl.slice(0, qIdx);
	const reqSearch = qIdx === -1 ? "" : reqUrl.slice(qIdx);
	const normalizedPath = reqPath ? reqPath[0] === "/" ? reqPath : "/" + reqPath : "/";
	let outgoingPath = options.toProxy ? "/" + reqUrl : normalizedPath + reqSearch;
	outgoingPath = options.ignorePath ? "" : outgoingPath;
	let fullPath = joinURL(targetPath, outgoingPath);
	if (targetSearch) fullPath = fullPath.includes("?") ? fullPath.replace("?", targetSearch + "&") : fullPath + targetSearch;
	outgoing.path = fullPath;
	if (options.changeOrigin) outgoing.headers.host = requiresPort(outgoing.port, options[forward || "target"].protocol) && !hasPort(outgoing.host) ? outgoing.host + ":" + outgoing.port : outgoing.host ?? void 0;
	return outgoing;
}
function joinURL(base, path) {
	if (!base || base === "/") return path || "/";
	if (!path || path === "/") return base || "/";
	const baseHasTrailing = base[base.length - 1] === "/";
	const pathHasLeading = path[0] === "/";
	if (baseHasTrailing && pathHasLeading) return base + path.slice(1);
	if (!baseHasTrailing && !pathHasLeading) return base + "/" + path;
	return base + path;
}
function setupSocket(socket) {
	socket.setTimeout(0);
	socket.setNoDelay(true);
	socket.setKeepAlive(true, 0);
	return socket;
}
function getPort(req) {
	const hostHeader = req.headers[":authority"] || req.headers.host;
	const res = hostHeader ? hostHeader.match(/:(\d+)/) : "";
	if (res) return res[1];
	return hasEncryptedConnection(req) ? "443" : "80";
}
function hasEncryptedConnection(req) {
	const socket = req.socket;
	return !!socket && "encrypted" in socket && socket.encrypted;
}
function rewriteCookieProperty(header, config, property) {
	if (Array.isArray(header)) return header.map(function(headerElement) {
		return rewriteCookieProperty(headerElement, config, property);
	});
	return header.replace(new RegExp(String.raw`(;\s*` + property + "=)([^;]+)", "i"), function(match, prefix, previousValue) {
		let newValue;
		if (previousValue in config) newValue = config[previousValue];
		else if ("*" in config) newValue = config["*"];
		else return match;
		return newValue ? prefix + newValue : "";
	});
}
function parseAddr(addr) {
	if (typeof addr === "string") {
		if (addr.startsWith("unix:")) return { socketPath: addr.slice(5) };
		const url = new URL(addr);
		return {
			host: url.hostname,
			port: Number(url.port) || (isSSL.test(url.protocol) ? 443 : 80)
		};
	}
	if (!addr.socketPath && !addr.port) throw new Error("ProxyAddr must have either `port` or `socketPath`");
	return addr;
}
function hasPort(host) {
	return host ? !!~host.indexOf(":") : false;
}
function requiresPort(_port, _protocol) {
	const protocol = _protocol?.split(":")[0];
	const port = +_port;
	if (!port) return false;
	switch (protocol) {
		case "http":
		case "ws": return port !== 80;
		case "https":
		case "wss": return port !== 443;
		case "ftp": return port !== 21;
		case "gopher": return port !== 70;
		case "file": return false;
	}
	return port !== 0;
}
function defineProxyMiddleware(m) {
	return m;
}
function defineProxyOutgoingMiddleware(m) {
	return m;
}
const redirectRegex = /^201|30([12378])$/;
const webOutgoingMiddleware = [
	defineProxyOutgoingMiddleware((req, res, proxyRes) => {
		if (req.httpVersion === "1.0" || req.httpVersionMajor >= 2 || proxyRes.statusCode === 204 || proxyRes.statusCode === 304) delete proxyRes.headers["transfer-encoding"];
	}),
	defineProxyOutgoingMiddleware((req, res, proxyRes) => {
		if (req.httpVersion === "1.0") proxyRes.headers.connection = req.headers.connection || "close";
		else if (req.httpVersionMajor < 2 && !proxyRes.headers.connection) proxyRes.headers.connection = req.headers.connection || "keep-alive";
		else if (req.httpVersionMajor >= 2) delete proxyRes.headers.connection;
	}),
	defineProxyOutgoingMiddleware((req, res, proxyRes, options) => {
		if ((options.hostRewrite || options.autoRewrite || options.protocolRewrite) && proxyRes.headers.location && redirectRegex.test(String(proxyRes.statusCode))) {
			const target = _toURL(options.target);
			const u = new URL(proxyRes.headers.location, target);
			if (target.host !== u.host) return;
			if (options.hostRewrite) u.host = options.hostRewrite;
			else if (options.autoRewrite) {
				if (req.headers[":authority"]) u.host = req.headers[":authority"];
				else if (req.headers.host) u.host = req.headers.host;
			}
			if (options.protocolRewrite) u.protocol = options.protocolRewrite;
			proxyRes.headers.location = u.toString();
		}
	}),
	defineProxyOutgoingMiddleware((req, res, proxyRes, options) => {
		const rewriteCookieDomainConfig = typeof options.cookieDomainRewrite === "string" ? { "*": options.cookieDomainRewrite } : options.cookieDomainRewrite;
		const rewriteCookiePathConfig = typeof options.cookiePathRewrite === "string" ? { "*": options.cookiePathRewrite } : options.cookiePathRewrite;
		const preserveHeaderKeyCase = options.preserveHeaderKeyCase;
		let rawHeaderKeyMap;
		const setHeader = function(key, header) {
			if (header === void 0 || !String(key).trim()) return;
			if (rewriteCookieDomainConfig && key.toLowerCase() === "set-cookie") header = rewriteCookieProperty(header, rewriteCookieDomainConfig, "domain");
			if (rewriteCookiePathConfig && key.toLowerCase() === "set-cookie") header = rewriteCookieProperty(header, rewriteCookiePathConfig, "path");
			try {
				res.setHeader(String(key).trim(), header);
			} catch {}
		};
		if (preserveHeaderKeyCase && proxyRes.rawHeaders !== void 0) {
			rawHeaderKeyMap = {};
			for (let i = 0; i < proxyRes.rawHeaders.length; i += 2) {
				const key = proxyRes.rawHeaders[i];
				rawHeaderKeyMap[key.toLowerCase()] = key;
			}
		}
		for (let key of Object.keys(proxyRes.headers)) {
			const header = proxyRes.headers[key];
			if (preserveHeaderKeyCase && rawHeaderKeyMap) key = rawHeaderKeyMap[key] || key;
			setHeader(key, header);
		}
	}),
	defineProxyOutgoingMiddleware((req, res, proxyRes) => {
		res.statusCode = proxyRes.statusCode;
		if (proxyRes.statusMessage && req.httpVersionMajor < 2) res.statusMessage = proxyRes.statusMessage;
	})
];
function _toURL(target) {
	if (target instanceof URL) return target;
	if (typeof target === "string") return new URL(target);
	const protocol = target.protocol || "http:";
	const host = target.host || target.hostname || "localhost";
	const port = target.port;
	return new URL(`${protocol}//${host}${port ? ":" + port : ""}`);
}
const nativeAgents = {
	http,
	https
};
const redirectStatuses = new Set([
	301,
	302,
	303,
	307,
	308
]);
const webIncomingMiddleware = [
	defineProxyMiddleware((req) => {
		if ((req.method === "DELETE" || req.method === "OPTIONS") && !req.headers["content-length"]) {
			req.headers["content-length"] = "0";
			delete req.headers["transfer-encoding"];
		}
	}),
	defineProxyMiddleware((req, res, options) => {
		if (options.timeout) req.socket.setTimeout(options.timeout, () => {
			req.socket.destroy();
		});
	}),
	defineProxyMiddleware((req, res, options) => {
		if (!options.xfwd) return;
		const encrypted = req.isSpdy || hasEncryptedConnection(req);
		const values = {
			for: req.connection.remoteAddress || req.socket.remoteAddress,
			port: getPort(req),
			proto: encrypted ? "https" : "http"
		};
		for (const header of [
			"for",
			"port",
			"proto"
		]) {
			const key = "x-forwarded-" + header;
			if (!req.headers[key] && values[header] !== void 0) req.headers[key] = values[header];
		}
		req.headers["x-forwarded-host"] = req.headers["x-forwarded-host"] || req.headers[":authority"] || req.headers.host || "";
	}),
	defineProxyMiddleware((req, res, options, server, head, callback) => {
		server.emit("start", req, res, options.target || options.forward);
		const http = nativeAgents.http;
		const https = nativeAgents.https;
		const maxRedirects = typeof options.followRedirects === "number" ? options.followRedirects : options.followRedirects ? 5 : 0;
		if (options.forward) {
			const forwardReq = (isSSL.test(options.forward.protocol || "http") ? https : http).request(setupOutgoing(options.ssl || {}, options, req, "forward"));
			const forwardError = createErrorHandler(forwardReq, options.forward);
			req.on("error", forwardError);
			forwardReq.on("error", forwardError);
			(options.buffer || req).pipe(forwardReq);
			if (!options.target) {
				res.end();
				return;
			}
		}
		const proxyReq = (isSSL.test(options.target.protocol || "http") ? https : http).request(setupOutgoing(options.ssl || {}, options, req));
		proxyReq.on("socket", (_socket) => {
			if (server && !proxyReq.getHeader("expect")) server.emit("proxyReq", proxyReq, req, res, options);
		});
		if (options.proxyTimeout) proxyReq.setTimeout(options.proxyTimeout, function() {
			proxyReq.destroy();
		});
		res.on("close", function() {
			if (!res.writableFinished) proxyReq.destroy();
		});
		const proxyError = createErrorHandler(proxyReq, options.target);
		req.on("error", proxyError);
		proxyReq.on("error", proxyError);
		function createErrorHandler(proxyReq, url) {
			return function proxyError(err) {
				if (!req.socket?.writable && err.code === "ECONNRESET") {
					server.emit("econnreset", err, req, res, url);
					return proxyReq.destroy();
				}
				if (callback) callback(err, req, res, url);
				else server.emit("error", err, req, res, url);
			};
		}
		let bodyBuffer;
		if (maxRedirects > 0) {
			const chunks = [];
			const source = options.buffer || req;
			source.on("data", (chunk) => {
				chunks.push(typeof chunk === "string" ? Buffer.from(chunk) : chunk);
				proxyReq.write(chunk);
			});
			source.on("end", () => {
				bodyBuffer = Buffer.concat(chunks);
				proxyReq.end();
			});
			source.on("error", (err) => {
				proxyReq.destroy(err);
			});
		} else proxyReq.on("socket", (socket) => {
			if (socket.pending) socket.on("connect", () => (options.buffer || req).pipe(proxyReq));
			else (options.buffer || req).pipe(proxyReq);
		});
		function handleResponse(proxyRes, redirectCount, currentUrl) {
			const statusCode = proxyRes.statusCode;
			if (maxRedirects > 0 && redirectStatuses.has(statusCode) && redirectCount < maxRedirects && proxyRes.headers.location) {
				proxyRes.resume();
				const location = new URL(proxyRes.headers.location, currentUrl);
				const preserveMethod = statusCode === 307 || statusCode === 308;
				const redirectMethod = preserveMethod ? req.method || "GET" : "GET";
				const isHTTPS = isSSL.test(location.protocol);
				const agent = isHTTPS ? https : http;
				const redirectHeaders = { ...req.headers };
				if (options.headers) Object.assign(redirectHeaders, options.headers);
				redirectHeaders.host = location.host;
				if (location.host !== currentUrl.host) {
					delete redirectHeaders.authorization;
					delete redirectHeaders.cookie;
				}
				if (!preserveMethod) {
					delete redirectHeaders["content-length"];
					delete redirectHeaders["content-type"];
					delete redirectHeaders["transfer-encoding"];
				}
				const redirectOpts = {
					hostname: location.hostname,
					port: location.port || (isHTTPS ? 443 : 80),
					path: location.pathname + location.search,
					method: redirectMethod,
					headers: redirectHeaders,
					agent: options.agent || false
				};
				if (isHTTPS) redirectOpts.rejectUnauthorized = options.secure === void 0 ? true : options.secure;
				const redirectReq = agent.request(redirectOpts);
				if (server && !redirectReq.getHeader("expect")) server.emit("proxyReq", redirectReq, req, res, options);
				if (options.proxyTimeout) redirectReq.setTimeout(options.proxyTimeout, () => {
					redirectReq.destroy();
				});
				const redirectError = createErrorHandler(redirectReq, location);
				redirectReq.on("error", redirectError);
				redirectReq.on("response", (nextRes) => {
					handleResponse(nextRes, redirectCount + 1, location);
				});
				if (preserveMethod && bodyBuffer && bodyBuffer.length > 0) redirectReq.end(bodyBuffer);
				else redirectReq.end();
				return;
			}
			if (server) server.emit("proxyRes", proxyRes, req, res);
			if (!res.headersSent && !options.selfHandleResponse) {
				for (const pass of webOutgoingMiddleware) if (pass(req, res, proxyRes, options)) break;
			}
			if (res.finished) {
				if (server) server.emit("end", req, res, proxyRes);
			} else {
				res.on("close", function() {
					proxyRes.destroy();
				});
				proxyRes.on("close", function() {
					if (!proxyRes.complete && !res.destroyed) res.destroy();
				});
				proxyRes.on("error", function(err) {
					if (!res.destroyed) res.destroy(err);
					if (server.listenerCount("error") > 0) server.emit("error", err, req, res, currentUrl);
				});
				proxyRes.on("end", function() {
					if (server) server.emit("end", req, res, proxyRes);
				});
				if (!options.selfHandleResponse) proxyRes.pipe(res);
			}
		}
		proxyReq.on("response", function(proxyRes) {
			handleResponse(proxyRes, 0, options.target);
		});
	})
];
const websocketIncomingMiddleware = [
	defineProxyMiddleware((req, socket) => {
		if (req.method !== "GET" || !req.headers.upgrade) {
			socket.destroy();
			return true;
		}
		if (req.headers.upgrade.toLowerCase() !== "websocket") {
			socket.destroy();
			return true;
		}
	}),
	defineProxyMiddleware((req, socket, options) => {
		if (!options.xfwd) return;
		const values = {
			for: req.connection.remoteAddress || req.socket.remoteAddress,
			port: getPort(req),
			proto: hasEncryptedConnection(req) ? "wss" : "ws"
		};
		for (const header of [
			"for",
			"port",
			"proto"
		]) {
			const key = "x-forwarded-" + header;
			if (!req.headers[key] && values[header] !== void 0) req.headers[key] = values[header];
		}
	}),
	defineProxyMiddleware((req, socket, options, server, head, callback) => {
		const createHttpHeader = function(line, headers) {
			return Object.keys(headers).reduce(function(head, key) {
				const value = headers[key];
				if (!Array.isArray(value)) {
					head.push(key + ": " + value);
					return head;
				}
				for (const element of value) head.push(key + ": " + element);
				return head;
			}, [line]).join("\r\n") + "\r\n\r\n";
		};
		setupSocket(socket);
		if (head && head.length > 0) socket.unshift(head);
		socket.on("error", onSocketError);
		const proxyReq = (isSSL.test(options.target.protocol || "http") ? https : http).request(setupOutgoing(options.ssl || {}, options, req));
		if (server) server.emit("proxyReqWs", proxyReq, req, socket, options, head);
		proxyReq.on("error", onOutgoingError);
		proxyReq.on("response", function(res) {
			if (!res.upgrade) if (!socket.destroyed && socket.writable) {
				socket.write(createHttpHeader("HTTP/" + res.httpVersion + " " + res.statusCode + " " + res.statusMessage, res.headers));
				res.on("error", onOutgoingError);
				res.pipe(socket);
			} else res.resume();
		});
		proxyReq.on("upgrade", function(proxyRes, proxySocket, proxyHead) {
			proxySocket.on("error", onOutgoingError);
			proxySocket.on("end", function() {
				server.emit("close", proxyRes, proxySocket, proxyHead);
			});
			socket.removeListener("error", onSocketError);
			socket.on("error", function() {
				proxySocket.end();
			});
			setupSocket(proxySocket);
			if (proxyHead && proxyHead.length > 0) proxySocket.unshift(proxyHead);
			socket.write(createHttpHeader("HTTP/1.1 101 Switching Protocols", proxyRes.headers));
			proxySocket.pipe(socket).pipe(proxySocket);
			server.emit("open", proxySocket);
			server.emit("proxySocket", proxySocket);
		});
		proxyReq.end();
		function onSocketError(err) {
			if (callback) callback(err, req, socket);
			else server.emit("error", err, req, socket);
			proxyReq.destroy();
		}
		function onOutgoingError(err) {
			if (callback) callback(err, req, socket);
			else server.emit("error", err, req, socket);
			socket.end();
		}
	})
];
var ProxyServer = class extends EventEmitter {
	_server;
	_webPasses = [...webIncomingMiddleware];
	_wsPasses = [...websocketIncomingMiddleware];
	options;
	web;
	ws;
	constructor(options = {}) {
		super();
		this.options = options || {};
		this.options.prependPath = options.prependPath !== false;
		this.web = _createProxyFn("web", this);
		this.ws = _createProxyFn("ws", this);
	}
	listen(port, hostname, listeningListener) {
		const closure = (req, res) => {
			return this.web(req, res);
		};
		if (this.options.http2) {
			if (!this.options.ssl) throw new Error("HTTP/2 requires ssl option");
			this._server = http2.createSecureServer({
				...this.options.ssl,
				allowHTTP1: true
			}, closure);
		} else if (this.options.ssl) this._server = https.createServer(this.options.ssl, closure);
		else this._server = http.createServer(closure);
		if (this.options.ws) this._server.on("upgrade", (req, socket, head) => {
			this.ws(req, socket, this.options, head).catch(() => {});
		});
		this._server.listen(port, hostname, listeningListener);
		return this;
	}
	close(callback) {
		if (this._server) this._server.close((...args) => {
			this._server = void 0;
			if (callback) Reflect.apply(callback, void 0, args);
		});
	}
	before(type, passName, pass) {
		if (type !== "ws" && type !== "web") throw new Error("type must be `web` or `ws`");
		const passes = this._getPasses(type);
		let i = false;
		for (const [idx, v] of passes.entries()) if (v.name === passName) i = idx;
		if (i === false) throw new Error("No such pass");
		passes.splice(i, 0, pass);
	}
	after(type, passName, pass) {
		if (type !== "ws" && type !== "web") throw new Error("type must be `web` or `ws`");
		const passes = this._getPasses(type);
		let i = false;
		for (const [idx, v] of passes.entries()) if (v.name === passName) i = idx;
		if (i === false) throw new Error("No such pass");
		passes.splice(i++, 0, pass);
	}
	_getPasses(type) {
		return type === "ws" ? this._wsPasses : this._webPasses;
	}
};
function createProxyServer(options = {}) {
	return new ProxyServer(options);
}
function _createProxyFn(type, server) {
	return function(req, res, opts, head) {
		const requestOptions = {
			...opts,
			...server.options
		};
		for (const key of ["target", "forward"]) if (typeof requestOptions[key] === "string") requestOptions[key] = new URL(requestOptions[key]);
		if (!requestOptions.target && !requestOptions.forward) {
			this.emit("error", /* @__PURE__ */ new Error("Must provide a proper URL as target"));
			return Promise.resolve();
		}
		let _resolve;
		let _reject;
		const callbackPromise = new Promise((resolve, reject) => {
			_resolve = resolve;
			_reject = reject;
		});
		res.on("close", () => {
			_resolve();
		});
		res.on("error", (error) => {
			_reject(error);
		});
		for (const pass of server._getPasses(type)) {
			let stop;
			try {
				stop = pass(req, res, requestOptions, server, head, (error, _req, _res, url) => {
					if (server.listenerCount("error") > 0) {
						server.emit("error", error, req, res, url);
						_resolve();
					} else _reject(error);
				});
			} catch (error) {
				if (server.listenerCount("error") > 0) {
					server.emit("error", error, req, res, requestOptions.target || requestOptions.forward);
					_resolve();
				} else _reject(error);
				break;
			}
			if (stop) {
				_resolve();
				break;
			}
		}
		return callbackPromise;
	};
}
async function proxyFetch(addr, input, inputInit, opts) {
	const resolvedAddr = parseAddr(addr);
	let useHTTPS = false;
	let addrBasePath = "";
	if (typeof addr === "string" && !addr.startsWith("unix:")) {
		const addrURL = new URL(addr);
		useHTTPS = isSSL.test(addrURL.protocol);
		if (addrURL.pathname && addrURL.pathname !== "/") addrBasePath = addrURL.pathname;
	}
	let url;
	let init;
	if (input instanceof Request) {
		url = new URL(input.url);
		init = {
			...toInit(input),
			...toInit(inputInit)
		};
	} else {
		url = new URL(input);
		init = toInit(inputInit);
	}
	init = {
		redirect: "manual",
		...init
	};
	if (init.body) init.duplex = "half";
	const requestPath = url.pathname + url.search;
	const path = addrBasePath ? joinURL(addrBasePath, requestPath) : requestPath;
	const reqHeaders = {};
	if (init.headers) if (!(init.headers instanceof Headers) && !Array.isArray(init.headers)) Object.assign(reqHeaders, init.headers);
	else for (const [key, value] of init.headers) {
		const existing = reqHeaders[key];
		if (existing === void 0) reqHeaders[key] = value;
		else reqHeaders[key] = Array.isArray(existing) ? [...existing, value] : [existing, value];
	}
	if (opts?.xfwd) {
		if (!reqHeaders["x-forwarded-for"]) reqHeaders["x-forwarded-for"] = url.hostname;
		if (!reqHeaders["x-forwarded-port"]) reqHeaders["x-forwarded-port"] = url.port || (url.protocol === "https:" ? "443" : "80");
		if (!reqHeaders["x-forwarded-proto"]) reqHeaders["x-forwarded-proto"] = url.protocol.replace(":", "");
		if (!reqHeaders["x-forwarded-host"]) reqHeaders["x-forwarded-host"] = url.host;
	}
	if (opts?.changeOrigin) if (resolvedAddr.socketPath) reqHeaders.host = "localhost";
	else {
		const targetHost = resolvedAddr.host || "localhost";
		const targetPort = resolvedAddr.port;
		reqHeaders.host = targetPort && targetPort !== (useHTTPS ? 443 : 80) ? `${targetHost}:${targetPort}` : targetHost;
	}
	const maxRedirects = typeof opts?.followRedirects === "number" ? opts.followRedirects : opts?.followRedirects ? 5 : 0;
	const body = maxRedirects > 0 ? await _bufferBody(init.body) : _toNodeStream(init.body);
	const agent = opts?.agent !== void 0 ? opts.agent || false : useHTTPS ? defaultAgents.https : defaultAgents.http;
	const res = await _sendRequest(useHTTPS ? request$1 : request, init.method || "GET", path, reqHeaders, resolvedAddr, body, {
		signal: init.signal || void 0,
		agent,
		timeout: opts?.timeout,
		ssl: opts?.ssl,
		maxRedirects,
		redirectCount: 0,
		originalHeaders: reqHeaders
	});
	const resHeaders = [];
	const rawHeaders = res.rawHeaders;
	for (let i = 0; i < rawHeaders.length; i += 2) {
		const key = rawHeaders[i];
		const keyLower = key.toLowerCase();
		if (keyLower === "transfer-encoding" || keyLower === "keep-alive" || keyLower === "connection") continue;
		resHeaders.push([key, rawHeaders[i + 1]]);
	}
	const hasBody = res.statusCode !== 204 && res.statusCode !== 304;
	return new Response(hasBody ? Readable.toWeb(res) : null, {
		status: res.statusCode,
		statusText: res.statusMessage,
		headers: resHeaders
	});
}
function toInit(init) {
	if (!init) return;
	if (init instanceof Request) return {
		method: init.method,
		headers: init.headers,
		body: init.body,
		duplex: init.body ? "half" : void 0
	};
	return init;
}
function _toNodeStream(body) {
	if (!body) return;
	if (typeof body === "string") return Buffer.from(body);
	if (body instanceof ArrayBuffer || ArrayBuffer.isView(body)) return Buffer.from(body);
	if (body instanceof ReadableStream) return Readable.fromWeb(body);
	if (body instanceof Blob) return Readable.fromWeb(body.stream());
	return Buffer.from(String(body));
}
async function _bufferBody(body) {
	if (!body) return;
	if (typeof body === "string") return Buffer.from(body);
	if (body instanceof ArrayBuffer || ArrayBuffer.isView(body)) return Buffer.from(body);
	if (body instanceof ReadableStream) {
		const readable = Readable.fromWeb(body);
		const chunks = [];
		for await (const chunk of readable) chunks.push(typeof chunk === "string" ? Buffer.from(chunk) : chunk);
		return Buffer.concat(chunks);
	}
	if (body instanceof Blob) return Buffer.from(await body.arrayBuffer());
	return Buffer.from(String(body));
}
const _redirectStatuses = new Set([
	301,
	302,
	303,
	307,
	308
]);
function _sendRequest(doRequest, method, path, headers, addr, body, opts) {
	return new Promise((resolve, reject) => {
		const reqOpts = {
			method,
			path,
			headers,
			agent: opts.agent
		};
		if (addr.socketPath) reqOpts.socketPath = addr.socketPath;
		else {
			reqOpts.hostname = addr.host || "localhost";
			reqOpts.port = addr.port;
		}
		if (opts.signal) reqOpts.signal = opts.signal;
		if (opts.ssl) Object.assign(reqOpts, opts.ssl);
		const req = doRequest(reqOpts, (res) => {
			const statusCode = res.statusCode;
			if (opts.maxRedirects > 0 && _redirectStatuses.has(statusCode) && opts.redirectCount < opts.maxRedirects && res.headers.location) {
				res.resume();
				const currentURL = new URL(path, `http://${addr.host || "localhost"}:${addr.port || 80}`);
				const location = new URL(res.headers.location, currentURL);
				const redirectHTTPS = isSSL.test(location.protocol);
				const preserveMethod = statusCode === 307 || statusCode === 308;
				const redirectMethod = preserveMethod ? method : "GET";
				const redirectHeaders = { ...opts.originalHeaders };
				redirectHeaders.host = location.host;
				if (location.host !== currentURL.host) {
					delete redirectHeaders.authorization;
					delete redirectHeaders.cookie;
				}
				if (!preserveMethod) {
					delete redirectHeaders["content-length"];
					delete redirectHeaders["content-type"];
					delete redirectHeaders["transfer-encoding"];
				}
				_sendRequest(redirectHTTPS ? request$1 : request, redirectMethod, location.pathname + location.search, redirectHeaders, {
					host: location.hostname,
					port: Number(location.port) || (redirectHTTPS ? 443 : 80)
				}, preserveMethod ? body : void 0, {
					...opts,
					redirectCount: opts.redirectCount + 1
				}).then(resolve, reject);
				return;
			}
			resolve(res);
		});
		req.on("error", reject);
		if (opts.timeout) req.setTimeout(opts.timeout, () => {
			req.destroy(/* @__PURE__ */ new Error("Proxy request timed out"));
		});
		if (body instanceof Readable) {
			body.on("error", (err) => {
				req.destroy(err);
				reject(err);
			});
			body.pipe(req);
		} else if (body) req.end(body);
		else req.end();
	});
}
function proxyUpgrade(addr, req, socket, head, opts) {
	const resolvedAddr = parseAddr(addr);
	let useSSL = false;
	if (typeof addr === "string" && !addr.startsWith("unix:")) useSSL = isSSL.test(new URL(addr).protocol);
	if (req.method !== "GET" || req.headers.upgrade?.toLowerCase() !== "websocket") {
		socket.destroy();
		return Promise.reject(/* @__PURE__ */ new Error("Not a valid WebSocket upgrade request"));
	}
	if (opts?.xfwd !== false) {
		const xfFor = req.headers["x-forwarded-for"];
		const xfPort = req.headers["x-forwarded-port"];
		const xfProto = req.headers["x-forwarded-proto"];
		req.headers["x-forwarded-for"] = `${xfFor ? `${xfFor},` : ""}${req.socket?.remoteAddress}`;
		req.headers["x-forwarded-port"] = `${xfPort ? `${xfPort},` : ""}${getPort(req)}`;
		req.headers["x-forwarded-proto"] = `${xfProto ? `${xfProto},` : ""}${hasEncryptedConnection(req) ? "wss" : "ws"}`;
	}
	const target = _buildTargetURL(resolvedAddr, useSSL);
	const requestOptions = {
		...opts,
		target,
		prependPath: opts?.prependPath !== false
	};
	const outgoing = setupOutgoing(requestOptions.ssl || {}, requestOptions, req);
	const sock = socket;
	return new Promise((resolve, reject) => {
		let settled = false;
		setupSocket(sock);
		if (head && head.length > 0) sock.unshift(head);
		sock.once("error", onSocketError);
		const proxyReq = (isSSL.test(target.protocol) ? request$1 : request)(outgoing);
		proxyReq.once("error", onOutgoingError);
		proxyReq.once("response", (res) => {
			if (!res.upgrade) {
				if (!sock.destroyed && sock.writable) {
					sock.write(_createHttpHeader(`HTTP/${res.httpVersion} ${res.statusCode} ${res.statusMessage}`, res.headers));
					res.on("error", onOutgoingError);
					res.pipe(sock);
				} else res.resume();
				if (!settled) {
					settled = true;
					reject(/* @__PURE__ */ new Error("Upstream server did not upgrade the connection"));
				}
			}
		});
		proxyReq.once("upgrade", (proxyRes, proxySocket, proxyHead) => {
			proxySocket.once("error", onOutgoingError);
			sock.removeListener("error", onSocketError);
			sock.once("error", () => {
				proxySocket.end();
			});
			setupSocket(proxySocket);
			if (proxyHead && proxyHead.length > 0) proxySocket.unshift(proxyHead);
			sock.write(_createHttpHeader("HTTP/1.1 101 Switching Protocols", proxyRes.headers));
			proxySocket.pipe(sock).pipe(proxySocket);
			settled = true;
			resolve(proxySocket);
		});
		proxyReq.end();
		function onSocketError(err) {
			proxyReq.destroy();
			if (!settled) {
				settled = true;
				reject(err);
			}
		}
		function onOutgoingError(err) {
			sock.end();
			if (!settled) {
				settled = true;
				reject(err);
			}
		}
	});
}
function _buildTargetURL(addr, useSSL = false) {
	const protocol = useSSL ? "https" : "http";
	if (addr.socketPath) {
		const url = new URL(`${protocol}://unix`);
		url.socketPath = addr.socketPath;
		return url;
	}
	return new URL(`${protocol}://${addr.host || "localhost"}${addr.port ? `:${addr.port}` : ""}`);
}
function _createHttpHeader(line, headers) {
	let result = line;
	for (const key of Object.keys(headers)) {
		const value = headers[key];
		if (value === void 0) continue;
		if (Array.isArray(value)) for (const element of value) result += `\r\n${key}: ${element}`;
		else result += `\r\n${key}: ${value}`;
	}
	return `${result}\r\n\r\n`;
}
export { ProxyServer, createProxyServer, proxyFetch, proxyUpgrade };
