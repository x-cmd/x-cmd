"""Compact TSV log: output current state as snapshot TSV."""
import sys, os
sys.path.insert(0, os.path.dirname(__file__))
from ondb_core import Ondb

db = Ondb()
db.load(sys.stdin)

# Entities: add + optional set for mtime
for eid in db._entity_order:
    e = db.entities[eid]
    if not e['alive']:
        continue
    cols = ['add', e['type'], eid, str(e['ctime'])]
    for k in e['props'].keys():
        v = e['props'][k]
        # Escape tabs/newlines in values like AWK _onto_escape
        v = v.replace('\\', '\\\\').replace('\t', '\\t').replace('\n', '\\n')
        cols.append(k)
        cols.append(v)
    print('\t'.join(cols))
    if e['mtime'] != e['ctime']:
        print(f"set\t{eid}\t{e['mtime']}")

# Links
for link in db.links:
    if link['from'] is None:
        continue
    cols = ['link', link['from'], link['rel'], link['to'], str(link['epoch'])]
    for k in link['props'].keys():
        v = link['props'][k]
        v = v.replace('\\', '\\\\').replace('\t', '\\t').replace('\n', '\\n')
        cols.append(k)
        cols.append(v)
    print('\t'.join(cols))
