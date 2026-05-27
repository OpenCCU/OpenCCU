import type * as http from 'node:http';
import type { Filter } from './types.js';
export declare function matchPathFilter<TReq extends http.IncomingMessage = http.IncomingMessage>(pathFilter: Filter<TReq> | undefined, uri: string | undefined, req: http.IncomingMessage): boolean;
