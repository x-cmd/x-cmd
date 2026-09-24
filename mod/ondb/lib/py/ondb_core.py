"""ondb core: parse TSV and provide query methods."""
import sys

class Ondb:
    def __init__(self):
        self.entities = {}   # id -> {type, ctime, mtime, alive, props, order}
        self.links = []      # [{from, rel, to, epoch, props}]
        self._entity_order = []
        self._link_map = {}  # (from, rel, to) -> link

    def load(self, lines):
        for line in lines:
            line = line.rstrip('\n')
            if not line:
                continue
            cols = line.split('\t')
            op = cols[0]
            if op == 'add':
                self._do_add(cols[1], cols[2], int(cols[3]), cols[4:])
            elif op == 'set':
                self._do_set(cols[1], int(cols[2]), cols[3:])
            elif op == 'rm':
                self._do_rm(cols[1])
            elif op == 'link':
                self._do_link(cols[1], cols[2], cols[3], int(cols[4]), cols[5:])
            elif op == 'unlink':
                self._do_unlink(cols[1], cols[2], cols[3])

    def _parse_props(self, cols):
        props = {}
        for i in range(0, len(cols), 2):
            if i + 1 < len(cols):
                k = cols[i]
                v = cols[i + 1]
                props[k] = v
        return props

    def _do_add(self, typ, eid, ts, props_cols):
        if eid in self.entities:
            return
        self.entities[eid] = {
            'type': typ, 'ctime': ts, 'mtime': ts,
            'alive': True, 'props': self._parse_props(props_cols),
            'order': len(self._entity_order)
        }
        self._entity_order.append(eid)

    def _do_set(self, eid, ts, props_cols):
        e = self.entities.get(eid)
        if not e or not e['alive']:
            return
        e['mtime'] = ts
        for i in range(0, len(props_cols), 2):
            if i + 1 < len(props_cols):
                k = props_cols[i]
                v = props_cols[i + 1]
                if v:
                    e['props'][k] = v
                else:
                    e['props'].pop(k, None)

    def _do_rm(self, eid):
        e = self.entities.get(eid)
        if e:
            e['alive'] = False

    def _do_link(self, fr, rel, to, ts, props_cols):
        key = (fr, rel, to)
        if key in self._link_map:
            return
        link = {'from': fr, 'rel': rel, 'to': to, 'epoch': ts,
                'props': self._parse_props(props_cols)}
        self.links.append(link)
        self._link_map[key] = link

    def _do_unlink(self, fr, rel, to):
        key = (fr, rel, to)
        if key in self._link_map:
            link = self._link_map.pop(key)
            link['from'] = None

    def ls(self, etype=None):
        out = []
        for eid in self._entity_order:
            e = self.entities[eid]
            if not e['alive']:
                continue
            if etype and e['type'] != etype:
                continue
            out.append((eid, e['type'], e['props'].get('name', '')))
        return out

    def linked(self, eid, rel=None, direction='outgoing'):
        out = []
        for link in self.links:
            if link['from'] is None:
                continue
            if direction == 'outgoing':
                if link['from'] != eid:
                    continue
            elif direction == 'incoming':
                if link['to'] != eid:
                    continue
            else:
                if link['from'] != eid and link['to'] != eid:
                    continue
            if rel and link['rel'] != rel:
                continue
            target = link['to'] if direction == 'outgoing' else link['from']
            e = self.entities.get(target)
            et = e['type'] if e and e['alive'] else ''
            out.append((link['rel'], target, et, link['props']))
        return out

    def get(self, eid):
        e = self.entities.get(eid)
        if not e or not e['alive']:
            return None
        return {
            'id': eid, 'type': e['type'],
            'ctime': e['ctime'], 'mtime': e['mtime'],
            'props': dict(e['props'])
        }

    def query(self, etype):
        return self.ls(etype)

    def related(self, eid, rel=None, direction='outgoing'):
        """Return related entities with full info (like ontology.py get_related)."""
        out = []
        for link in self.links:
            if link['from'] is None:
                continue
            if direction == 'outgoing':
                if link['from'] != eid:
                    continue
            elif direction == 'incoming':
                if link['to'] != eid:
                    continue
            else:
                if link['from'] != eid and link['to'] != eid:
                    continue
            if rel and link['rel'] != rel:
                continue
            target = link['to'] if direction == 'outgoing' else link['from']
            e = self.entities.get(target)
            if not e or not e['alive']:
                continue
            out.append({
                'relation': link['rel'],
                'direction': direction,
                'entity': {
                    'id': target,
                    'type': e['type'],
                    'props': dict(e['props'])
                }
            })
        return out

    def validate(self):
        """Basic validation: check dangling links."""
        errors = []
        for link in self.links:
            if link['from'] is None:
                continue
            if link['from'] not in self.entities or not self.entities[link['from']]['alive']:
                errors.append(f"dangling_from: link from={link['from']} rel={link['rel']} to={link['to']}")
            if link['to'] not in self.entities or not self.entities[link['to']]['alive']:
                errors.append(f"dangling_to: link from={link['from']} rel={link['rel']} to={link['to']}")
        return errors
