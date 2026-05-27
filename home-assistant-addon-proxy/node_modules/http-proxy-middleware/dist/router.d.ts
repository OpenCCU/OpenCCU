import type * as http from 'node:http';
import type { Options } from './index.js';
export declare function getTarget<TReq extends http.IncomingMessage = http.IncomingMessage, TRes extends http.ServerResponse = http.ServerResponse>(req: TReq, config: Options<TReq, TRes>): Promise<import("httpxy").ProxyTarget | undefined>;
