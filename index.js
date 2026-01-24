const http = require('http');

http.createServer((req, res) => {

  // 🔥 AUTH'DAN MUSTAQIL HEALTH
  if (req.url === '/healthz') {
    res.writeHead(200);
    res.end('OK');
    return;
  }

  // pastda AUTH / LOGIN / boshqa logic
  if (req.url === '/health') {
    res.writeHead(200);
    res.end('OK');
    return;
  }

  // qolgan routing
  res.end('Node.js is running ' + new Date());

}).listen(3000);
