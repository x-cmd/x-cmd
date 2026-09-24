import { Ondb } from './ondb_core.js';

let eid = '';
for (let i = 2; i < Bun.argv.length; i++) {
  const a = Bun.argv[i];
  if (a.startsWith('--id=')) eid = a.slice(5);
}

const db = new Ondb();
const input = await Bun.stdin.text();
db.load(input);

const e = db.get(eid);
if (e) {
  const out = [
    `id\t${e.id}`,
    `type\t${e.type}`,
    `ctime\t${e.ctime}`,
    `mtime\t${e.mtime}`
  ];
  for (const k in e.props) {
    out.push(`prop\t${k}=${e.props[k]}`);
  }
  process.stdout.write(out.join('\n') + '\n');
}
