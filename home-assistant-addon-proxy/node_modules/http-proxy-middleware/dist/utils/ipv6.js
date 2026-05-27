import { Debug } from '../debug.js';
const debug = Debug.extend('ipv6');
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
export function normalizeIPv6LiteralTargets(options) {
    options.target = normalizeIPv6ProxyTarget(options.target, 'target');
    options.forward = normalizeIPv6ProxyTarget(options.forward, 'forward');
}
function normalizeIPv6ProxyTarget(target, optionName) {
    const targetUrl = toTargetUrl(target);
    if (targetUrl && isBracketedIPv6Hostname(targetUrl.hostname)) {
        debug('normalized IPv6 "%s" %s', optionName, target);
        return {
            hostname: stripBrackets(targetUrl.hostname),
            pathname: targetUrl.pathname,
            port: targetUrl.port,
            protocol: targetUrl.protocol,
            search: targetUrl.search,
        };
    }
    return target;
}
function toTargetUrl(target) {
    if (typeof target === 'string') {
        return new URL(target);
    }
    if (target instanceof URL) {
        return target;
    }
    return undefined;
}
function isBracketedIPv6Hostname(hostname) {
    return hostname.startsWith('[') && hostname.endsWith(']');
}
function stripBrackets(hostname) {
    return hostname.replace(/^\[|\]$/g, '');
}
