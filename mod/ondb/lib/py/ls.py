import sys, os
sys.path.insert(0, os.path.dirname(__file__))
from ondb_core import Ondb

etype = ''
if len(sys.argv) > 1 and sys.argv[1].startswith('--type='):
    etype = sys.argv[1].split('=', 1)[1]

db = Ondb()
db.load(sys.stdin)
for eid, typ, name in db.ls(etype or None):
    print(f"{eid}\t{typ}\t{name}")
