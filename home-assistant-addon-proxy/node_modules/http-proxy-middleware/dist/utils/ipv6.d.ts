import type * as http from 'node:http';
import type { Options } from '../types.js';
/**
 * Normalize bracketed IPv6 URL targets into unbracketed host options.
 *
 * RFC 2732 defines the URL syntax for literal IPv6 addresses as bracketed
 * host references (for example `http://[::1]:8080/path` where host is
 * `[::1]`).
 *
 * `httpxy` resolves bracketed hostnames (for example `[::1]`) via DNS,
 * which can fail for IPv6 literals. This converts string/URL `target` and
 * `forward` values into object form with `hostname: ::1` (brackets removed)
 * so the address can be connected directly.
 *
 * Reference: RFC 2732, Section 2 (Literal IPv6 Address Format in URL's)
 * https://www.ietf.org/rfc/rfc2732.txt
 *
 * The provided options object is mutated in place.
 */
export declare function normalizeIPv6LiteralTargets<TReq extends http.IncomingMessage = http.IncomingMessage, TRes extends http.ServerResponse = http.ServerResponse>(options: Options<TReq, TRes>): void;
