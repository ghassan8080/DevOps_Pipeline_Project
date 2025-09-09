const express = require('express');
const si = require('systeminformation');
const client = require('prom-client');

// إنشاء تطبيق Express
const app = express();
const PORT = process.env.PORT || 3000;

// إنشاء سجل Prometheus
const register = new client.Registry();

// إضافة المقاييس الافتراضية من Prometheus
client.collectDefaultMetrics({ register });

// تعريف المقاييس المخصصة
const httpRequestCounter = new client.Counter({
  name: 'node_app_http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'route', 'status_code']
});

const httpRequestDuration = new client.Histogram({
  name: 'node_app_http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route'],
  buckets: [0.1, 0.5, 1, 1.5, 2, 5]
});

const systemMemoryUsage = new client.Gauge({
  name: 'node_app_system_memory_usage_bytes',
  help: 'System memory usage in bytes'
});

const systemCpuUsage = new client.Gauge({
  name: 'node_app_system_cpu_usage_percent',
  help: 'System CPU usage percentage'
});

const appUptime = new client.Gauge({
  name: 'node_app_uptime_seconds',
  help: 'Application uptime in seconds'
});

const activeConnections = new client.Gauge({
  name: 'node_app_active_connections',
  help: 'Number of active connections'
});

// تسجيل المقاييس المخصصة
register.registerMetric(httpRequestCounter);
register.registerMetric(httpRequestDuration);
register.registerMetric(systemMemoryUsage);
register.registerMetric(systemCpuUsage);
register.registerMetric(appUptime);
register.registerMetric(activeConnections);

// متغير لتتبع الاتصالات النشطة
let activeConnectionsCount = 0;

// تحديث المقاييس بشكل دوري
setInterval(async () => {
  try {
    // الحصول على معلومات الذاكرة
    const memory = await si.mem();
    systemMemoryUsage.set(memory.used);

    // الحصول على معلومات وحدة المعالجة المركزية
    const cpu = await si.currentLoad();
    systemCpuUsage.set(cpu.currentLoad);

    // تحديث وقت تشغيل التطبيق
    appUptime.set(process.uptime());

    // تحديث عدد الاتصالات النشطة
    activeConnections.set(activeConnectionsCount);
  } catch (error) {
    console.error('Error updating metrics:', error);
  }
}, 10000); // تحديث كل 10 ثوانٍ

// Middleware لتتبع الطلبات
app.use((req, res, next) => {
  const start = Date.now();

  // زيادة عدد الاتصالات النشطة
  activeConnectionsCount++;

  res.on('finish', () => {
    // تقليل عدد الاتصالات النشطة
    activeConnectionsCount--;

    // زيادة عداد الطلبات
    httpRequestCounter.inc({
      method: req.method,
      route: req.route ? req.route.path : req.path,
      status_code: res.statusCode
    });

    // تسجيل مدة الطلب
    const duration = (Date.now() - start) / 1000;
    httpRequestDuration.observe({
      method: req.method,
      route: req.route ? req.route.path : req.path
    }, duration);
  });

  next();
});

// نقاط نهاية التطبيق
app.get('/', (req, res) => {
  res.send(`
    <html>
      <head>
        <title>Node.js Monitoring App</title>
        <style>
          body { font-family: Arial, sans-serif; margin: 40px; }
          .container { max-width: 800px; margin: 0 auto; }
          .card { background: #f8f9fa; border-radius: 8px; padding: 20px; margin-bottom: 20px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
          h1 { color: #343a40; }
          .metric { margin-bottom: 10px; }
          .metric-name { font-weight: bold; }
          .metric-value { color: #007bff; }
        </style>
      </head>
      <body>
        <div class="container">
          <h1>Node.js Monitoring App</h1>
          <div class="card">
            <h2>Application Metrics</h2>
            <div class="metric">
              <span class="metric-name">Active Connections:</span>
              <span class="metric-value">${activeConnectionsCount}</span>
            </div>
            <div class="metric">
              <span class="metric-name">Uptime:</span>
              <span class="metric-value">${Math.floor(process.uptime())} seconds</span>
            </div>
          </div>
          <div class="card">
            <h2>Monitoring Endpoints</h2>
            <p><a href="/metrics">/metrics</a> - Prometheus metrics endpoint</p>
            <p><a href="/health">/health</a> - Application health status</p>
            <p><a href="/system">/system</a> - System information</p>
          </div>
        </div>
      </body>
    </html>
  `);
});

// نقطة نهاية للمقاييس
app.get('/metrics', async (req, res) => {
  try {
    res.set('Content-Type', register.contentType);
    res.end(await register.metrics());
  } catch (error) {
    res.status(500).end(error);
  }
});

// نقطة نهاية للتحقق من صحة التطبيق
app.get('/health', (req, res) => {
  res.json({
    status: 'UP',
    uptime: process.uptime(),
    timestamp: Date.now(),
    memoryUsage: process.memoryUsage(),
    activeConnections: activeConnectionsCount
  });
});

// نقطة نهاية لمعلومات النظام
app.get('/system', async (req, res) => {
  try {
    const [cpu, mem, osInfo] = await Promise.all([
      si.currentLoad(),
      si.mem(),
      si.osInfo()
    ]);

    res.json({
      cpu: {
        usage: cpu.currentLoad,
        cores: cpu.cpus.length
      },
      memory: {
        total: mem.total,
        used: mem.used,
        free: mem.free,
        percentage: (mem.used / mem.total) * 100
      },
      os: {
        platform: osInfo.platform,
        distro: osInfo.distro,
        release: osInfo.release,
        kernel: osInfo.kernel
      },
      uptime: process.uptime(),
      activeConnections: activeConnectionsCount
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// بدء تشغيل الخادم
app.listen(PORT, () => {
  console.log(`Node.js monitoring app running on port ${PORT}`);
  console.log(`Metrics available at http://localhost:${PORT}/metrics`);
});
