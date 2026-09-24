import { Ondb } from './ondb_core.js';

const db = new Ondb();
const input = await Bun.stdin.text();
db.load(input);

const out = [];

// Entities
for (let i = 0; i < db._entity_order.length; i++) {
  const eid = db._entity_order[i];
  const e = db.entities.get(eid);
  if (!e || !e.alive) continue;
  const parts = ['add', e.type, eid, String(e.ctime)];
  for (const k in e.props) {
    let v = e.props[k];
    if (v.indexOf('\\') >= 0 || v.indexOf('\t') >= 0 || v.indexOf('\n') >= 0) {
      v = v.replaceAll('\\', '\\\\').replaceAll('\t', '\\t').replaceAll('\n', '\\n');
    }
    parts.push(k, v);
  }
  out.push(parts.join('\t'));
  if (e.mtime !== e.ctime) {
    out.push(`set\t${eid}\t${e.mtime}`);
  }
}

// Links
for (let i = 0; i < db.links.length; i++) {
  const link = db.links[i];
  if (link.from === null) continue;
  const parts = ['link', link.from, link.rel, link.to, String(link.epoch)];
  for (const k in link.props) {
    let v = link.props[k];
    if (v.indexOf('\\') >= 0 || v.indexOf('\t') >= 0 || v.indexOf('\n') >= 0) {
      v = v.replaceAll('\\', '\\\\').replaceAll('\t', '\\t').replaceAll('\n', '\\n');
    }
    parts.push(k, v);
  }
  out.push(parts.join('\t'));
}

process.stdout.write(out.join('\n') + '\n');
