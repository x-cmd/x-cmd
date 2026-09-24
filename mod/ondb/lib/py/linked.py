import sys, os
sys.path.insert(0, os.path.dirname(__file__))
from ondb_core import Ondb

eid = ''; rel = ''; direction = 'outgoing'
for a in sys.argv[1:]:
    if a.startswith('--id='): eid = a.split('=', 1)[1]
    elif a.startswith('--rel='): rel = a.split('=', 1)[1]
    elif a.startswith('--datadir='): direction = a.split('=', 1)[1]

db = Ondb()
db.load(sys.stdin)
for r, target, et, props in db.linked(eid, rel or None, direction):
    cols = [r, target, et]
    for k in props.keys():
        v = props[k]
        v = v.replace('\\', '\\\\').replace('\t', '\\t').replace('\n', '\\n')
        cols.append(f"{k}={v}")
    print('\t'.join(cols))
