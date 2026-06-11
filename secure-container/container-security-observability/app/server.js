'use strict';

const http = require('http');
const { Registry, Counter, Histogram, Gauge } = require('prom-client');

const register = new Registry();
register.setDefaultLabels({ app: 'demo-api', version: process.env.APP_VERSION || '1.0.0' });

// ── Métricas ──────────────────────────────────────────────────────────────────
const httpRequests = new Counter({
  name: 'http_requests_total',
  help: 'Total HTTP requests',
  labelNames: ['method', 'route', 'status_code'],
  registers: [register],
});

const httpDuration = new Histogram({
  name: 'http_request_duration_seconds',
  help: 'HTTP request duration in seconds',
  labelNames: ['method', 'route', 'status_code'],
  buckets: [0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2.5],
  registers: [register],
});

const activeRequests = new Gauge({
  name: 'http_active_requests',
  help: 'Currently active HTTP requests',
  registers: [register],
});

const appInfo = new Gauge({
  name: 'app_info',
  help: 'Application build info',
  labelNames: ['version', 'node_version'],
  registers: [register],
});
appInfo.labels(process.env.APP_VERSION || '1.0.0', process.version).set(1);

// ── Router simple ─────────────────────────────────────────────────────────────
const routes = {
  'GET /': (res) => {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({
      service: 'demo-api',
      version: process.env.APP_VERSION || '1.0.0',
      status: 'ok',
      timestamp: new Date().toISOString(),
    }));
  },
  'GET /health': (res) => {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ status: 'healthy', uptime: process.uptime() }));
  },
  'GET /ready': (res) => {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ status: 'ready' }));
  },
  'GET /metrics': async (res) => {
    const metrics = await register.metrics();
    res.writeHead(200, { 'Content-Type': register.contentType });
    res.end(metrics);
  },
  'GET /items': (res) => {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({
      items: [
        { id: 1, name: 'Container Security', category: 'devsecops' },
        { id: 2, name: 'Observability',      category: 'devsecops' },
        { id: 3, name: 'GitOps',             category: 'devsecops' },
      ],
    }));
  },
};

// ── Server ────────────────────────────────────────────────────────────────────
const PORT = process.env.PORT || 3000;

const server = http.createServer(async (req, res) => {
  const start = Date.now();
  const key = `${req.method} ${req.url}`;
  activeRequests.inc();

  const handler = routes[key];
  if (handler) {
    await handler(res);
  } else {
    res.writeHead(404, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ error: 'Not found' }));
  }

  const duration = (Date.now() - start) / 1000;
  const route = handler ? req.url : '/404';
  httpRequests.labels(req.method, route, String(res.statusCode)).inc();
  httpDuration.labels(req.method, route, String(res.statusCode)).observe(duration);
  activeRequests.dec();
});

server.listen(PORT, '0.0.0.0', () => {
  console.log(JSON.stringify({
    level: 'info',
    msg: `Server listening on port ${PORT}`,
    pid: process.pid,
    version: process.env.APP_VERSION || '1.0.0',
  }));
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log(JSON.stringify({ level: 'info', msg: 'SIGTERM received, shutting down gracefully' }));
  server.close(() => process.exit(0));
});
