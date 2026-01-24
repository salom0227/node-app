const http = require('http');

http.createServer((req, res) => {
  if (req.url === '/health') {
    res.writeHead(200);
    res.end('OK');
    return;
  }

  res.end('Node.js AUTO DEPLOY ISHLAYAPTI v2 🚀 ' + new Date());
}).listen(3000);

