// PHONG CHUNG BANG DOAN — server Node.js (thay HttpListener sau khi soi http.sys zombie + PS5.1 quirks)
// API giong y heht: GET /messages?since=N | POST /messages {from,to,text} | GET /ping | GET /members | GET / = UI
const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = 8788;
const ROOT = __dirname;
const DATA = path.join(ROOT, 'tin-nhan.json');
const WWW = path.join(ROOT, 'www');

function readMsgs() {
  try {
    const raw = fs.readFileSync(DATA, 'utf8');
    const arr = JSON.parse(raw);
    return Array.isArray(arr) ? arr : [];
  } catch (e) { return []; }
}
function writeMsgs(arr) {
  const tmp = DATA + '.tmp';
  fs.writeFileSync(tmp, JSON.stringify(arr, null, 1), 'utf8');   // ghi tam
  fs.renameSync(tmp, DATA);                                       // rename cung volume = atomic
}
function json(res, code, obj) {
  const body = JSON.stringify(obj);
  res.writeHead(code, { 'Content-Type': 'application/json; charset=utf-8', 'X-Room-Version': '3.1-node' });
  res.end(body);
}

const server = http.createServer((req, res) => {
  const url = new URL(req.url, 'http://localhost:' + PORT);
  const p = url.pathname;

  if (p === '/' || p === '/index.html') {
    fs.readFile(path.join(WWW, 'index.html'), (err, buf) => {
      if (err) { res.writeHead(500); res.end('err'); return; }
      res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
      res.end(buf);
    });
  }
  else if (p === '/ping') {
    json(res, 200, { pong: true, version: '3.1-node' });
  }
  else if (p === '/messages' && req.method === 'GET') {
    const since = parseInt(url.searchParams.get('since') || '0', 10) || 0;
    let msgs = readMsgs().filter(m => m.id > since);
    if (since === 0 && msgs.length > 100) msgs = msgs.slice(-100);
    json(res, 200, msgs);
  }
  else if (p === '/messages' && req.method === 'POST') {
    let body = '';
    let tooBig = false;
    req.on('data', c => { body += c; if (body.length > 102400) { tooBig = true; req.destroy(); } });
    req.on('end', () => {
      if (tooBig) { json(res, 413, { error: 'payload qua lon (toi da 100KB)' }); return; }
      let b;
      try { b = JSON.parse(body); } catch (e) { json(res, 400, { error: 'body khong phai JSON' }); return; }
      if (!b.from || !String(b.from).trim()) { json(res, 400, { error: 'from khong duoc rong' }); return; }
      if (!b.text || !String(b.text).trim()) { json(res, 400, { error: 'text khong duoc rong' }); return; }
      const msgs = readMsgs();
      const max = msgs.length ? Math.max(...msgs.map(m => m.id)) : 0;
      const msg = { id: max + 1, from: String(b.from), to: String(b.to || 'Cả phòng'), text: String(b.text), ts: new Date().toISOString().slice(0, 19).replace('T', ' ') };
      // Archive khi >= 500 tin (giu 100 gan nhat trong file chinh)
      let out = msgs;
      if (out.length >= 500) {
        const old = out.slice(0, out.length - 100);
        const arcFile = path.join(ROOT, 'tin-nhan-luu.json');
        let arc = [];
        try { arc = JSON.parse(fs.readFileSync(arcFile, 'utf8')); } catch (e) {}
        fs.writeFileSync(arcFile, JSON.stringify(arc.concat(old), null, 1), 'utf8');
        out = out.slice(-100);
      }
      out.push(msg);
      writeMsgs(out);
      json(res, 200, msg);
    });
  }
  else if (p === '/members') {
    const msgs = readMsgs();
    const by = {};
    for (const m of msgs) { (by[m.from] = by[m.from] || { name: m.from, tin: 0, cuoi: m.ts }); by[m.from].tin++; by[m.from].cuoi = m.ts; }
    json(res, 200, Object.values(by));
  }
  else {
    json(res, 404, { error: 'not found', path: p });
  }
});

server.listen(PORT, '127.0.0.1', () => {
  // Backup tu dong moi lan boot — bai hoc 15-16/11: lich su phong mat vi ghi de khong backup
  try {
    const bak = path.join(ROOT, 'tin-nhan-backup-' + new Date().toISOString().slice(0, 16).replace(/[:T-]/g, '') + '.json');
    fs.copyFileSync(DATA, bak);
    const baks = fs.readdirSync(ROOT).filter(f => f.startsWith('tin-nhan-backup-')).sort();
    while (baks.length > 10) { fs.unlinkSync(path.join(ROOT, baks.shift())); }  // giu 10 ban moi nhat
    console.log('backup tin-nhan oke: ' + path.basename(bak));
  } catch (e) { console.log('backup skip: ' + e.message); }
  console.log('[' + new Date().toISOString().slice(11, 19) + '] PHONG CHAT NODE: http://localhost:' + PORT + ' — 1 process, event loop, khong http.sys');
});
