const http = require('http');

const PORT = process.env.PORT || 3000;

// إنشاء خادم HTTP
const server = http.createServer((req, res) => {
  // تعيين رأس الاستجابة
  res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });

  // معالجة الطلبات حسب المسار
  if (req.url === '/' || req.url === '/index.html') {
    res.end(`
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
                <span class="metric-name">Uptime:</span>
                <span class="metric-value">${Math.floor(process.uptime())} seconds</span>
              </div>
              <div class="metric">
                <span class="metric-name">Memory Usage:</span>
                <span class="metric-value">${Math.round(process.memoryUsage().heapUsed / 1024 / 1024)} MB</span>
              </div>
            </div>
            <div class="card">
              <h2>Monitoring Endpoints</h2>
              <p><a href="/metrics">/metrics</a> - Simple metrics endpoint</p>
              <p><a href="/health">/health</a> - Application health status</p>
            </div>
          </div>
        </body>
      </html>
    `);
  } else if (req.url === '/metrics') {
    res.writeHead(200, { 'Content-Type': 'text/plain' });
    res.end(`# HELP node_app_uptime_seconds Application uptime in seconds
# TYPE node_app_uptime_seconds gauge
node_app_uptime_seconds ${process.uptime()}

# HELP node_app_memory_usage_bytes Memory usage in bytes
# TYPE node_app_memory_usage_bytes gauge
node_app_memory_usage_bytes ${process.memoryUsage().heapUsed}

# HELP node_app_http_requests_total Total number of HTTP requests
# TYPE node_app_http_requests_total counter
node_app_http_requests_total{method="GET",route="/metrics"} 1
node_app_http_requests_total{method="GET",route="/health"} 1
node_app_http_requests_total{method="GET",route="/"} 1`);
  } else if (req.url === '/health') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({
      status: 'UP',
      uptime: process.uptime(),
      timestamp: Date.now(),
      memoryUsage: process.memoryUsage()
    }));
  } else {
    // صفحة 404 للطلبات غير المعروفة
    res.writeHead(404, { 'Content-Type': 'text/html; charset=utf-8' });
    res.end('<h1>404 - الصفحة غير موجودة</h1><p>الرجاء العودة إلى <a href="/">الصفحة الرئيسية</a></p>');
  }
});

// بدء تشغيل الخادم
server.listen(PORT, () => {
  console.log(`Node.js monitoring app running on port ${PORT}`);
  console.log(`Metrics available at http://localhost:${PORT}/metrics`);
});
