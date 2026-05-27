/**
 * Get port from target
 * Using proxyRes.req.agent.sockets to determine the target port
 */
export function getPort(sockets) {
    return Object.keys(sockets || {})?.[0]?.split(':')[1];
}
