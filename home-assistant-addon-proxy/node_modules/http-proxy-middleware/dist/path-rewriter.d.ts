import type { IncomingMessage } from 'node:http';
import type { PathRewriteConfig } from './types.js';
/**
 * Create rewrite function, to cache parsed rewrite rules.
 */
export declare function createPathRewriter<TReq extends IncomingMessage = IncomingMessage>(rewriteConfig: PathRewriteConfig<TReq> | undefined): ((path: string, req: TReq) => string | undefined) | ((path: string, req: TReq) => Promise<string>) | undefined;
