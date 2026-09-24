import { Ondb } from './ondb_core.js';

let etype = '';
for (let i = 2; i < Bun.argv.length; i++) {
  const a = Bun.argv[i];
  if (a.startsWith('--type=')) etype = a.slice(7);
}

const db = new Ondb();
const input = await Bun.stdin.text();
db.load(input);

const out = [];
for (let i = 0; i < db._entity_order.length; i++) {
  const eid = db._entity_order[i];
  const e = db.entities.get(eid);
  if (!e || !e.alive) continue;
  if (etype && e.type !== etype) continue;
  out.push(`${eid}\t${e.type}\t${e.props.name || ''}`);
}
process.stdout.write(out.join('\n') + '\n');
