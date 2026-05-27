import type * as http from 'node:http';
import type { Options, Plugin } from './types.js';
export declare function getPlugins<TReq extends http.IncomingMessage, TRes extends http.ServerResponse>(options: Options<TReq, TRes>): Plugin<TReq, TRes>[];
