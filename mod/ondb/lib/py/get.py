import sys, os
sys.path.insert(0, os.path.dirname(__file__))
from ondb_core import Ondb

eid = ''
for a in sys.argv[1:]:
    if a.startswith('--id='): eid = a.split('=', 1)[1]

db = Ondb()
db.load(sys.stdin)
e = db.get(eid)
if e:
    print(f"id\t{e['id']}")
    print(f"type\t{e['type']}")
    print(f"ctime\t{e['ctime']}")
    print(f"mtime\t{e['mtime']}")
    for k, v in e['props'].items():
        print(f"prop\t{k}={v}")
