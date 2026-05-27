import { createProxyServer } from 'httpxy';
import { verifyConfig } from './configuration.js';
import { Debug as debug } from './debug.js';
import { getPlugins } from './get-plugins.js';
import { getLogger } from './logger.js';
import { matchPathFilter } from './path-filter.js';
import { createPathRewriter } from './path-rewriter.js';
import { getTarget } from './router.js';
import { getFunctionName } from './utils/function.js';
import { normalizeIPv6LiteralTargets } from './utils/ipv6.js';
export class HttpProxyMiddleware {
    wsInternalSubscribed = false;
    serverOnCloseSubscribed = false;
    proxyOptions;
    proxy;
    pathRewriter;
    logger;
    constructor(options) {
        verifyConfig(options);
        this.proxyOptions = options;
        this.logger = getLogger(options);
        debug(`create proxy server`);
        this.proxy = createProxyServer({});
        this.registerPlugins(this.proxy, this.proxyOptions);
        this.pathRewriter = createPathRewriter(this.proxyOptions.pathRewrite); // returns undefined when "pathRewrite" is not provided
        // https://github.com/chimurai/http-proxy-middleware/issues/19
        // expose function to upgrade externally
        this.middleware.upgrade = (req, socket, head) => {
            if (!this.wsInternalSubscribed) {
                this.handleUpgrade(req, socket, head);
            }
        };
    }
    // https://github.com/Microsoft/TypeScript/wiki/'this'-in-TypeScript#red-flags-for-this
    middleware = (async (req, res, next) => {
        if (this.shouldProxy(this.proxyOptions.pathFilter, req)) {
            let activeProxyOptions;
            try {
                // Preparation Phase: Apply router and path rewriter.
                activeProxyOptions = await this.prepareProxyRequest(req);
                // [Smoking Gun] httpxy is inconsistent with error handling:
                // 1. If target is missing (here), it emits 'error' but returns a boolean (bypassing our catch/next).
                // 2. If a network error occurs (in proxy.web), it rejects the promise but SKIPS emitting 'error'.
                // We manually throw here to force Case 1 into the catch block so next(err) is called for Express.
                if (!activeProxyOptions.target && !activeProxyOptions.forward) {
                    throw new Error('Must provide a proper URL as target');
                }
            }
            catch (err) {
                next?.(err);
                return;
            }
            try {
                // Proxying Phase: Handle the actual web request.
                debug(`proxy request to target: %O`, activeProxyOptions.target);
                await this.proxy.web(req, res, activeProxyOptions);
            }
            catch (err) {
                // Manually emit 'error' event because httpxy's promise-based API does not emit it automatically.
                // This is crucial for backward compatibility with HPM plugins (like error-response-plugin)
                // and custom listeners registered via the 'on: { error: ... }' option.
                this.proxy.emit('error', err, req, res, activeProxyOptions.target);
                next?.(err);
            }
        }
        else {
            next?.();
        }
        /**
         * Get the server object to subscribe to server events;
         * 'upgrade' for websocket and 'close' for graceful shutdown
         */
        const server = req.socket?.server;
        if (server && !this.serverOnCloseSubscribed) {
            server.on('close', () => {
                debug('server close signal received: closing proxy server');
                this.proxy.close(() => {
                    debug('proxy server closed');
                });
            });
            this.serverOnCloseSubscribed = true;
        }
        if (this.proxyOptions.ws === true && server) {
            // use initial request to access the server object to subscribe to http upgrade event
            this.catchUpgradeRequest(server);
        }
    });
    registerPlugins(proxy, options) {
        const plugins = getPlugins(options);
        plugins.forEach((plugin) => {
            debug(`register plugin: "${getFunctionName(plugin)}"`);
            plugin(proxy, options);
        });
    }
    catchUpgradeRequest = (server) => {
        if (!this.wsInternalSubscribed) {
            debug('subscribing to server upgrade event');
            server.on('upgrade', this.handleUpgrade);
            // prevent duplicate upgrade handling;
            // in case external upgrade is also configured
            this.wsInternalSubscribed = true;
        }
    };
    handleUpgrade = async (req, socket, head) => {
        try {
            if (this.shouldProxy(this.proxyOptions.pathFilter, req)) {
                const proxiedReq = req;
                const activeProxyOptions = await this.prepareProxyRequest(proxiedReq);
                await this.proxy.ws(proxiedReq, socket, activeProxyOptions, head);
                debug('server upgrade event received. Proxying WebSocket');
            }
        }
        catch (err) {
            // This error does not include the URL as the fourth argument as we won't
            // have the URL if `this.prepareProxyRequest` throws an error.
            this.proxy.emit('error', err, req, socket);
        }
    };
    /**
     * Determine whether request should be proxied.
     */
    shouldProxy = (pathFilter, req) => {
        try {
            return matchPathFilter(pathFilter, req.url, req);
        }
        catch (err) {
            debug('Error: matchPathFilter() called with request url: ', `"${req.url}"`);
            this.logger.error(err);
            return false;
        }
    };
    /**
     * Apply option.router and option.pathRewrite
     * Order matters:
     *    Router uses original path for routing;
     *    NOT the modified path, after it has been rewritten by pathRewrite
     * @param {Object} req
     * @return {Object} proxy options
     */
    prepareProxyRequest = async (req) => {
        const newProxyOptions = Object.assign({}, this.proxyOptions);
        // Apply in order:
        // 1. option.router
        // 2. option.pathRewrite
        await this.applyRouter(req, newProxyOptions);
        normalizeIPv6LiteralTargets(newProxyOptions);
        await this.applyPathRewrite(req, this.pathRewriter);
        return newProxyOptions;
    };
    // Modify option.target when router present.
    applyRouter = async (req, options) => {
        let newTarget;
        if (options.router) {
            newTarget = await getTarget(req, options);
            if (newTarget) {
                debug('router new target: "%s"', newTarget);
                options.target = newTarget;
            }
        }
    };
    // rewrite path
    applyPathRewrite = async (req, pathRewriter) => {
        if (req.url && pathRewriter) {
            const path = await pathRewriter(req.url, req);
            if (typeof path === 'string') {
                debug('pathRewrite new path: %s', path);
                req.url = path;
            }
            else {
                debug('pathRewrite: no rewritten path found: %s', req.url);
            }
        }
    };
}
