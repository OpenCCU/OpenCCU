#!/usr/bin/env node
//
// Node.js based HTTP proxy to rewrite the Location: and non-relative
// urls used in the HomeMatic WebUI of HTTP requests coming from
// Home-Assistent UI so that the Ingress-based HA UI is able to embed
// the WebUI.
//
// Copyright (c) 2021-2024 Jens Maus <mail@jens-maus.de>
// Apache 2.0 License applies
//
// v1.0: initial version
// v1.1: adapted to http-proxy-middleware v3
//

const express = require('express');
const { createProxyMiddleware, responseInterceptor } = require('http-proxy-middleware');
const ipaddr = require('ipaddr.js');

const apiProxy = createProxyMiddleware({
  target: 'http://127.0.0.1:80',
  pathFilter: '/',
  changeOrigin: true, // for vhosted sites
  //logger: console,
  selfHandleResponse: true,
  timeout: 1200000, // max 20 min
  on: {
    proxyRes: responseInterceptor(async (responseBody, proxyRes, req, res) => {
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
}, apiProxy);
app.listen(8099);
