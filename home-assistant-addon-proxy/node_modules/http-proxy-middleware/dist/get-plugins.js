import { debugProxyErrorsPlugin, errorResponsePlugin, loggerPlugin, proxyEventsPlugin, } from './plugins/default/index.js';
export function getPlugins(options) {
    // don't load default errorResponsePlugin if user has specified their own
    const maybeErrorResponsePlugin = options.on?.error ? [] : [errorResponsePlugin];
    const defaultPlugins = options.ejectPlugins
        ? [] // no default plugins when ejecting
        : [debugProxyErrorsPlugin, proxyEventsPlugin, loggerPlugin, ...maybeErrorResponsePlugin];
    const userPlugins = options.plugins ?? [];
    return [...defaultPlugins, ...userPlugins];
}
