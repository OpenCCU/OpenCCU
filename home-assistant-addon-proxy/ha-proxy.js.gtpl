#!/usr/bin/env node
//
// Node.js based HTTP proxy to rewrite the Location: and non-relative
// urls used in the HomeMatic WebUI of HTTP requests coming from
// Home-Assistent UI so that the Ingress-based HA UI is able to embed
// the WebUI.
//
// Copyright (c) 2021-2026 Jens Maus <mail@jens-maus.de>
// Apache 2.0 License applies
//
// v1.0: initial version
// v1.1: adapted to http-proxy-middleware v3
// v1.2: implement session sid cookie storage
//

const express = require('express');
const { createProxyMiddleware, responseInterceptor } = require('http-proxy-middleware');
const ipaddr = require('ipaddr.js');

// increase default listener limit
require('events').EventEmitter.defaultMaxListeners = 40;

const REQUEST_TIMEOUT = 20 * 60 * 1000; // 20 min
const SID_COOKIE = 'openccu_ingress_sid';

function parseCookies(header) {
  return Object.fromEntries((header || '').split(';').flatMap(cookie => {
    const separator = cookie.indexOf('=');
    if(separator < 0) return [];
    try {
      return [[cookie.slice(0, separator).trim(), decodeURIComponent(cookie.slice(separator + 1).trim())]];
    } catch(error) {
      return [];
    }
  }));
}

function validSid(sid) {
  return typeof(sid) === 'string' && sid.length > 0 && sid.length <= 256 && /^[A-Za-z0-9@._-]+$/.test(sid);
}

function sidCookie(sid, ingressPath, clear = false) {
  const path = ingressPath && ingressPath.startsWith('/') ? ingressPath : '/';
  return `${SID_COOKIE}=${clear ? '' : encodeURIComponent(sid)}; Path=${path}; HttpOnly; SameSite=Lax${clear ? '; Max-Age=0' : ''}`;
}

function clearSidCookie(res, ingressPath) {
  res.append('Set-Cookie', sidCookie('', ingressPath, true));
}

function isIngressIndexPath(path) {
  return path.endsWith('/index.htm');
}

function removeSidFromUrl(url) {
  const [path, queryString] = String(url || '').split('?', 2);
  if(typeof(queryString) === 'undefined') return path || '/';
  const params = new URLSearchParams(queryString);
  params.delete('sid');
  const query = params.toString();
  return query.length > 0 ? `${path}?${query}` : path;
}

const apiProxy = createProxyMiddleware({
  target: '{{ index . "webui-url" }}',
  pathFilter: '/',
  changeOrigin: true, // for vhosted sites
  //logger: console,
  selfHandleResponse: true,
  // Use upstream proxyTimeout here; incoming client-facing timeouts are set once on the server below.
  proxyTimeout: REQUEST_TIMEOUT,
  on: {
    proxyRes: responseInterceptor(async (responseBody, proxyRes, req, res) => {
      const ingressPath = req.headers['x-ingress-path'] || '/';
      const rememberedSid = parseCookies(req.headers.cookie)[SID_COOKIE];
      const querySid = req.query.sid;

      if(proxyRes.statusCode === 500 &&
         isIngressIndexPath(req.path) &&
         validSid(querySid) &&
         validSid(rememberedSid) &&
         querySid === rememberedSid) {
        clearSidCookie(res, ingressPath);
        res.statusCode = 302;
        res.setHeader('location', `${ingressPath}${removeSidFromUrl(req.originalUrl)}`);
        return '';
      }

      // modify Location: response header if present
      if(typeof(proxyRes.headers.location) !== 'undefined') {
        // replace any absolute http/https path with a relative one
        var redirect = proxyRes.headers.location.replace(/(http|https):\/\/(.*?)\//, '/');
        redirect = req.headers['x-ingress-path'] + redirect;
        res.setHeader('location', redirect);
      }

      // modifying textual response bodies
      if(proxyRes.headers['content-type'] &&
         (
          proxyRes.headers['content-type'].includes('text/') ||
          proxyRes.headers['content-type'].includes('application/javascript') ||
          proxyRes.headers['content-type'].includes('application/json')
         )
        ) {

        var body;

        // if this a textual response body we make sure to prepend the ingress path
        if(proxyRes.headers['content-type'].toLowerCase().includes('utf-8') || proxyRes.req.path.includes('/jpages/')) {
          body = responseBody.toString('utf8');
        } else {
          body = responseBody.toString('latin1');
        }

        body = body.replace(/(?<=["'= \(\\]|\\u0027)\/(api|webui|ise|pda|config|pages|jpages|esp|upnp|tools|addons|tailscale)(\\?\/)(?!hassio_ingress)/g,
                            req.headers['x-ingress-path']+'/$1$2');
        body = body.replace(/(?<=["'])\/(index|login|logout)\.htm/g,
                            req.headers['x-ingress-path']+'/$1.htm');
        body = body.replace(/window\.location\.href='\/'/g,
                            'window.location.href=\'' + req.headers['x-ingress-path'] + '/\'');
        body = body.replace(/window\.location\.href='\/index\.htm'/g,
                            'window.location.href=\'' + req.headers['x-ingress-path'] + '/index.htm\'');

        // convert back to a Buffer in the right character encoding
        if(typeof(req.headers['content-type']) === 'undefined' && req.path.includes('/jpages/') === false) {
          return new Buffer.from(body, 'latin1');
        } else {
          return new Buffer.from(body, 'utf8');
        }
      } else {
        return responseBody;
      }
    }),
  },
});

const app = express();
app.use((req, res, next) => {
  //Get whitelisted range
  let whitelisted_range = ipaddr.parseCIDR(process.env.HM_HAPROXY_SRC);
  //Get source IP
  let source_ip = ipaddr.parse(req.ip.split(':').pop());
  //Check if source IP in whitelisted range
  if(source_ip.match(whitelisted_range)) {
    // allowed, forward to next middleware (proxy)
    next();
  } else {
    // abort request with "403 Forbidden"
    res.status(403).end();
  }
}, (req, res, next) => {
  const ingressPath = req.headers['x-ingress-path'] || '/';
  const isLogout = req.path === '/logout.htm';

  if(isLogout) {
    clearSidCookie(res, ingressPath);
    return next();
  }

  const rememberedSid = parseCookies(req.headers.cookie)[SID_COOKIE];
  if(validSid(req.query.sid)) {
    if(!validSid(rememberedSid) || rememberedSid === req.query.sid) {
      res.append('Set-Cookie', sidCookie(req.query.sid, ingressPath));
    }
    return next();
  }

  if(isIngressIndexPath(req.path) && validSid(rememberedSid)) {
    const originalUrlWithoutSid = removeSidFromUrl(req.originalUrl);
    const querySeparator = originalUrlWithoutSid.includes('?') ? '&' : '?';
    return res.redirect(302, `${ingressPath}${originalUrlWithoutSid}${querySeparator}sid=${encodeURIComponent(rememberedSid)}`);
  }

  next();
}, apiProxy);

// listen on port 8099
const server = app.listen(8099, (err) => {
  if(err) {
    console.error(`ERROR: could not start ha-proxy: ${err}`);
  } else {
    console.log('Serving proxy requests for ' + '{{ index . "webui-url" }}' + ' on port 8099.');
  }
});

server.setTimeout(REQUEST_TIMEOUT);
server.requestTimeout = REQUEST_TIMEOUT;
