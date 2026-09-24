/**
 * ondb JavaScript library - entry point.
 * 
 * Usage:
 *   import { Ondb } from './ontology.js';
 *   
 *   const ondb = new Ondb();
 *   const text = await Bun.file('ondb.tsv').text();
 *   ondb.load(text);
 *   
 *   // Query
 *   for (const [eid, etype, name] of ondb.ls('Task')) {
 *     console.log(eid, name);
 *   }
 *   
 *   // Get related entities
 *   for (const rel of ondb.related('t1', 'depends_on', 'outgoing')) {
 *     console.log(rel.relation, rel.entity.id);
 *   }
 *   
 *   // Validate
 *   const errors = ondb.validate();
 *   for (const err of errors) {
 *     console.log(err);
 *   }
 */

import { Ondb } from './ondb_core.js';

export { Ondb };
