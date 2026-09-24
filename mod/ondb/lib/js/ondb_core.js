/**
 * ondb core: parse TSV and provide query methods.
 * Optimized for bun runtime.
 */

class Ondb {
  constructor() {
    this.entities = new Map();
    this.links = [];
    this._entity_order = [];
    this._link_map = new Map();
  }

  load(text) {
    let start = 0;
    const len = text.length;
    while (start < len) {
      let end = text.indexOf('\n', start);
      if (end === -1) end = len;
      if (end > start) {
        const line = text.slice(start, end);
        const cols = line.split('\t');
        const op = cols[0];
        if (op === 'add') {
          this._do_add(cols[1], cols[2], +cols[3], cols, 4);
        } else if (op === 'set') {
          this._do_set(cols[1], +cols[2], cols, 3);
        } else if (op === 'rm') {
          this._do_rm(cols[1]);
        } else if (op === 'link') {
          this._do_link(cols[1], cols[2], cols[3], +cols[4], cols, 5);
        } else if (op === 'unlink') {
          this._do_unlink(cols[1], cols[2], cols[3]);
        }
      }
      start = end + 1;
    }
  }

  _parse_props(cols, from) {
    const props = {};
    for (let i = from; i < cols.length; i += 2) {
      if (i + 1 < cols.length) {
        props[cols[i]] = cols[i + 1];
      }
    }
    return props;
  }

  _do_add(typ, eid, ts, cols, from) {
    if (this.entities.has(eid)) return;
    this.entities.set(eid, {
      type: typ, ctime: ts, mtime: ts,
      alive: true, props: this._parse_props(cols, from)
    });
    this._entity_order.push(eid);
  }

  _do_set(eid, ts, cols, from) {
    const e = this.entities.get(eid);
    if (!e || !e.alive) return;
    e.mtime = ts;
    for (let i = from; i < cols.length; i += 2) {
      if (i + 1 < cols.length) {
        const k = cols[i];
        const v = cols[i + 1];
        if (v) {
          e.props[k] = v;
        } else {
          delete e.props[k];
        }
      }
    }
  }

  _do_rm(eid) {
    const e = this.entities.get(eid);
    if (e) e.alive = false;
  }

  _do_link(fr, rel, to, ts, cols, from) {
    const key = fr + '\t' + rel + '\t' + to;
    if (this._link_map.has(key)) return;
    const link = { from: fr, rel, to, epoch: ts, props: this._parse_props(cols, from) };
    this.links.push(link);
    this._link_map.set(key, link);
  }

  _do_unlink(fr, rel, to) {
    const key = fr + '\t' + rel + '\t' + to;
    const link = this._link_map.get(key);
    if (link) {
      link.from = null;
      this._link_map.delete(key);
    }
  }

  ls(etype = null) {
    const out = [];
    for (let i = 0; i < this._entity_order.length; i++) {
      const eid = this._entity_order[i];
      const e = this.entities.get(eid);
      if (!e || !e.alive) continue;
      if (etype && e.type !== etype) continue;
      out.push([eid, e.type, e.props.name || '']);
    }
    return out;
  }

  get(eid) {
    const e = this.entities.get(eid);
    if (!e || !e.alive) return null;
    return {
      id: eid, type: e.type,
      ctime: e.ctime, mtime: e.mtime,
      props: { ...e.props }
    };
  }

  query(etype = null) {
    return this.ls(etype);
  }

  related(eid, rel = null, direction = 'outgoing') {
    const out = [];
    for (let i = 0; i < this.links.length; i++) {
      const link = this.links[i];
      if (link.from === null) continue;
      if (direction === 'outgoing') {
        if (link.from !== eid) continue;
      } else if (direction === 'incoming') {
        if (link.to !== eid) continue;
      } else {
        if (link.from !== eid && link.to !== eid) continue;
      }
      if (rel && link.rel !== rel) continue;
      const target = direction === 'outgoing' ? link.to : link.from;
      const e = this.entities.get(target);
      if (!e || !e.alive) continue;
      out.push({
        relation: link.rel,
        direction,
        entity: { id: target, type: e.type, props: { ...e.props } }
      });
    }
    return out;
  }

  validate() {
    const errors = [];
    for (let i = 0; i < this.links.length; i++) {
      const link = this.links[i];
      if (link.from === null) continue;
      const from_e = this.entities.get(link.from);
      const to_e = this.entities.get(link.to);
      if (!from_e || !from_e.alive) {
        errors.push(`dangling_from: link from=${link.from} rel=${link.rel} to=${link.to}`);
      }
      if (!to_e || !to_e.alive) {
        errors.push(`dangling_to: link from=${link.from} rel=${link.rel} to=${link.to}`);
      }
    }
    return errors;
  }
}

module.exports = { Ondb };
