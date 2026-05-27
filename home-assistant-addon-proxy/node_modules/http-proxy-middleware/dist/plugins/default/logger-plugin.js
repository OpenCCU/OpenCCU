import { URL } from 'node:url';
import { getLogger } from '../../logger.js';
import { createUrl } from '../../utils/create-url.js';
import { getPort } from '../../utils/logger-plugin.js';
export const loggerPlugin = (proxyServer, options) => {
    const logger = getLogger(options);
    proxyServer.on('error', (err, req, res, target) => {
        const hostname = req?.headers?.host;
        const requestHref = `${hostname}${req?.url}`;
        const targetHref = `${target?.href}`; // target is undefined when websocket errors
        const errorMessage = '[HPM] Error occurred while proxying request %s to %s [%s] (%s)';
        const errReference = 'https://nodejs.org/api/errors.html#errors_common_system_errors'; // link to Node Common Systems Errors page
        logger.error(errorMessage, requestHref, targetHref, err.code || err, errReference);
    });
    /**
     * Log request and response
     * @example
     * ```shell
     * [HPM] GET /users/ -> http://jsonplaceholder.typicode.com/users/ [304]
     * ```
     */
    proxyServer.on('proxyRes', (proxyRes, req, res) => {
        // BrowserSync uses req.originalUrl
        // Next.js doesn't have req.baseUrl
        const originalUrl = req.originalUrl ?? `${req.baseUrl || ''}${req.url}`;
        // construct targetUrl
        let target;
        try {
            const port = getPort(proxyRes.req?.agent?.sockets);
            const { protocol, host, path } = proxyRes.req;
            target = createUrl({ protocol, host, port, path });
        }
        catch (err) {
            // should not error. keeping fallback just in case
            console.error('[HPM] Unexpected error while creating target URL', err);
            // fallback to old implementation (less correct - without port)
            target = new URL(options.target);
            target.pathname = proxyRes.req.path;
        }
        const targetUrl = target.toString();
        const exchange = `[HPM] ${req.method} ${originalUrl} -> ${targetUrl} [${proxyRes.statusCode}]`;
        logger.info(exchange);
    });
    /**
     * When client opens WebSocket connection
     */
    proxyServer.on('open', (socket) => {
        logger.info('[HPM] Client connected: %o', socket.address());
    });
    /**
     * When client closes WebSocket connection
     */
    proxyServer.on('close', (req, proxySocket, proxyHead) => {
        logger.info('[HPM] Client disconnected: %o', proxySocket.address());
    });
};
