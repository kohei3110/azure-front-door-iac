'use strict';

const express = require('express');
const path = require('path');

const app = express();
app.disable('x-powered-by');

const siteDir = path.join(__dirname, 'site');

function setCommonSecurityHeaders(res) {
  // Keep it minimal & safe for static sites.
  res.setHeader('X-Content-Type-Options', 'nosniff');
  res.setHeader('Referrer-Policy', 'strict-origin-when-cross-origin');
  res.setHeader('X-Frame-Options', 'DENY');
  // If you embed this site in an iframe intentionally, change/remove X-Frame-Options.
}

app.use((req, res, next) => {
  setCommonSecurityHeaders(res);
  next();
});

// Health endpoints for Azure Front Door / App Service checks.
app.get('/health', (_req, res) => {
  res.status(200).type('text/plain').send('OK');
});

// Cache policy:
// - HTML: no-store (so updates reflect quickly)
// - versioned assets: long cache
function setStaticCacheHeaders(res, filePath) {
  const ext = path.extname(filePath).toLowerCase();

  if (ext === '.html') {
    res.setHeader('Cache-Control', 'no-store');
    return;
  }

  if (filePath.includes(`${path.sep}assets${path.sep}`)) {
    // Assets are referenced with a version query in HTML; long cache is OK.
    res.setHeader('Cache-Control', 'public, max-age=31536000, immutable');
    return;
  }

  // Default: cache but not too aggressively.
  res.setHeader('Cache-Control', 'public, max-age=300');
}

// Serve assets first with strong caching.
app.use(
  '/assets',
  express.static(path.join(siteDir, 'assets'), {
    maxAge: '365d',
    immutable: true,
    setHeaders: (res, filePath) => {
      setCommonSecurityHeaders(res);
      setStaticCacheHeaders(res, filePath);
    }
  })
);

// Serve well-known files (usually should reflect quickly).
app.use(
  '/.well-known',
  express.static(path.join(siteDir, '.well-known'), {
    setHeaders: (res, filePath) => {
      setCommonSecurityHeaders(res);
      // Make updates visible quickly.
      res.setHeader('Cache-Control', 'public, max-age=300');
      // security.txt can be cached shortly; adjust if needed.
      if (path.basename(filePath).toLowerCase() === 'security.txt') {
        res.setHeader('Cache-Control', 'public, max-age=300');
      }
    }
  })
);

// Serve remaining static files.
app.use(
  express.static(siteDir, {
    setHeaders: (res, filePath) => {
      setCommonSecurityHeaders(res);
      setStaticCacheHeaders(res, filePath);
    }
  })
);

// Custom 404 to return a real 404 status (Front Door might rewrite, but origin should be correct too).
app.use((req, res) => {
  res.status(404);
  res.sendFile(path.join(siteDir, '404.html'));
});

const port = Number(process.env.PORT) || 3000;

app.listen(port, () => {
  // App Service log stream will show this line.
  console.log(`Static origin server listening on port ${port}`);
});
