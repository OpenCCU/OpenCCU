import type * as http from 'node:http';
import type { Options } from './types.js';
export declare function verifyConfig<TReq extends http.IncomingMessage, TRes extends http.ServerResponse>(options: Options<TReq, TRes>): void;
