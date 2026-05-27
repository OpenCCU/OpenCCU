import { getStatusCode } from '../../status-code.js';
import { sanitize } from '../../utils/sanitize.js';
function isResponseLike(obj) {
    return obj && typeof obj.writeHead === 'function';
}
function isSocketLike(obj) {
    return obj && typeof obj.write === 'function' && !('writeHead' in obj);
}
export const errorResponsePlugin = (proxyServer, options) => {
    proxyServer.on('error', (err, req, res, target) => {
        // Re-throw error. Not recoverable since req & res are empty.
        if (!req || !res) {
            throw err; // "Error: Must provide a proper URL as target"
        }
        if (isResponseLike(res)) {
            if (!res.headersSent) {
                const statusCode = getStatusCode(err.code);
                res.writeHead(statusCode);
            }
            const host = req.headers && req.headers.host;
            res.end(`Error occurred while trying to proxy: ${sanitize(host)}${sanitize(req.url)}`);
        }
        else if (isSocketLike(res)) {
            res.destroy();
        }
    });
};
