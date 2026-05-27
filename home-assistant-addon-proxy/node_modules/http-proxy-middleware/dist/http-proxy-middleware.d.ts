import type * as http from 'node:http';
import type { Options, RequestHandler } from './types.js';
export declare class HttpProxyMiddleware<TReq extends http.IncomingMessage = http.IncomingMessage, TRes extends http.ServerResponse = http.ServerResponse> {
    private wsInternalSubscribed;
    private serverOnCloseSubscribed;
    private proxyOptions;
    private proxy;
    private pathRewriter;
    private logger;
    constructor(options: Options<TReq, TRes>);
    middleware: RequestHandler<TReq, TRes>;
    private registerPlugins;
    private catchUpgradeRequest;
    private handleUpgrade;
    /**
     * Determine whether request should be proxied.
     */
    private shouldProxy;
    /**
     * Apply option.router and option.pathRewrite
     * Order matters:
     *    Router uses original path for routing;
     *    NOT the modified path, after it has been rewritten by pathRewrite
     * @param {Object} req
     * @return {Object} proxy options
     */
    private prepareProxyRequest;
    private applyRouter;
    private applyPathRewrite;
}
