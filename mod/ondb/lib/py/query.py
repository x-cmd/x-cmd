import sys, os
sys.path.insert(0, os.path.dirname(__file__))
from ondb_core import Ondb

etype = ''
for a in sys.argv[1:]:
    if a.startswith('--type='): etype = a.split('=', 1)[1]

db = Ondb()
db.load(sys.stdin)
for eid, typ, name in db.query(etype or None):
    print(f"{eid}\t{typ}\t{name}")
