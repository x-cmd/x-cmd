---
name: ontology-database
description: Typed knowledge graph via TSV append-only log — entity CRUD, directed relations, schema validation, multi-hop reasoning. CLI via `x ondb`, protocol readable by AWK/Python/JS/SQLite.
---

# Ontology Database (ondb)

Typed knowledge graph: everything is an **entity** (id + type + properties) connected by **directed relations** (from → rel → to). All mutations append TSV lines — never overwrite. The TSV log IS the database.

## TSV log format (the protocol)

```
add     <type>  <id>  <epoch_ms>  key1  val1  key2  val2       # create entity
set     <id>  <epoch_ms>  key  val                             # update property
rm      <id>  <epoch_ms>                                       # delete entity
link    <from>  <rel>  <to>  <epoch_ms>  [key1  val1 ...]     # create relation
unlink  <from>  <rel>  <to>  <epoch_ms>                        # remove relation
# tab-separated; escape: \t → tab, \n → newline, \\ → backslash
# properties are alternating key/val pairs (each is a separate tab field)
```

Any language reads this. AWK streams, Python dicts, SQLite materializes. **Log is source of truth.**

## CLI usage

```
x ondb add --type Person --name Alice                            # auto UUID
x ondb add --type Task --name "Fix bug" --id t1 priority=high status=open
x ondb get --id t1 --json                                       # entity detail
x ondb set --id t1 status=done                                  # update prop
x ondb rm --id t1                                               # delete

x ondb link --from proj_001 --rel has_task --to t1              # create relation
x ondb link --from t1 --rel blocks --to t2                      # with link props: -- status=hard
x ondb linked --id proj_001 --rel has_task                      # outgoing relations
x ondb linked --id t1 --direction incoming                      # incoming (who links TO)
x ondb related --id proj_001 --rel has_task --json              # full entity on other side

x ondb ls --type Task                                           # list by type
x ondb query --type Task --where status=open --json             # filter by props
```

`linked` = relation metadata. `related` = full entity on the other side. Use `--dir <path>` / `-d <path>` for data directory (→ `path/ondb.tsv`).

## Schema & validation

```
x ondb schema add "type:Task:required:title,status"
x ondb schema add "type:Task:enum:status:open,in_progress,done,blocked"
x ondb schema add "relation:blocks:from_types:Task"
x ondb schema add "relation:blocks:acyclic:1"
x ondb validate                          # checks required, enum, dangling refs, cardinality, cycles
```

Directives: `type:Name:{required|forbidden|enum|datetime|ref}:...`, `relation:Rel:{from_types|to_types|cardinality|acyclic}:...`. Validation is separate from write.

## Architecture principles

- **Log is source** — TSV log is authoritative; SQLite is a materialized view
- **Append-only** — `set`, `rm`, `unlink` append lines; never modify existing lines
- **Multiple instances** — one ondb per sub-domain (default); merge only for cross-domain chains
- **Type = Concept** — same type name always means the same concept
- **Validate on demand** — no schema check at write; run `validate` after batch changes

## Backends

| Backend | When | |
|---|---|---|
| **AWK** (default) | < 2k entities | Zero deps, streaming |
| Python | Medium | Rich data structures |
| JS/Bun | Web apps | JSON native |
| SQLite | > 5k entities | Auto-generated from TSV log |

## Directory structure

```
<datadir>/ONDB.DESC.txt    # Required. Identifies ondb instance
<datadir>/ondb.tsv         # Append-only log
<datadir>/schema.tsv       # Optional. Constraints
<datadir>/ondb.db          # Optional. SQLite materialized view
```

## For more information

- `x ondb --help` — CLI reference
- `x ondb libpath {awk,py,js}` — library paths for custom queries
- [ondb SKILL.md](../../../ondb/SKILL.md) — full docs (scenarios, integration, custom queries, SQLite WAL config)
