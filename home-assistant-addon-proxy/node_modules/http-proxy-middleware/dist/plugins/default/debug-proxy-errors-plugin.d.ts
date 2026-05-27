import type { Plugin } from '../../types.js';
/**
 * Subscribe to {@link https://github.com/unjs/httpxy#events `httpxy` error events} to prevent server from crashing.
 * Errors are logged with {@link https://www.npmjs.com/package/debug debug} library.
 */
export declare const debugProxyErrorsPlugin: Plugin;
