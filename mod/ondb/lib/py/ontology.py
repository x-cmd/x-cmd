"""
ondb Python library - entry point.

Usage:
    from ontology import Ondb
    
    ondb = Ondb()
    with open('ondb.tsv') as f:
        ondb.load(f)
    
    # Query
    for eid, etype, name in ondb.ls('Task'):
        print(eid, name)
    
    # Get related entities
    for rel in ondb.related('t1', 'depends_on', 'outgoing'):
        print(rel['relation'], rel['entity']['id'])
    
    # Validate
    errors = ondb.validate()
    for err in errors:
        print(err)
"""
import sys
import os

# Add parent directory to path for importing ondb_core
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from ondb_core import Ondb

__all__ = ['Ondb']
