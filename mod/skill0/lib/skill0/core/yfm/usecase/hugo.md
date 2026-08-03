# Hugo

Docs: <https://gohugo.io/content-management/front-matter/>

## Typical example

```markdown
+++
title = 'Front matter'
date = 2024-02-02T04:14:54-08:00
draft = false
weight = 10
tags = ['red', 'blue']
keywords = ['front matter', 'metadata']
+++
```

Delimiters are `+++`, content is TOML — not YAML. That is the first trap of this dialect.

## Tag extraction

- **key** — `tags`, `categories`, `keywords`, plus **site-configured taxonomy**
- **type** — `[]string` array

**Key names are not fixed.** Taxonomy is defined in the site's `[taxonomies]` config and may be called anything — `series`, `authors`, etc. From the file alone you cannot enumerate tag keys; the collector must read `hugo.toml` / `config.yaml` `[taxonomies]`. The collector for Hugo can only do **known keys + config supplement**; assuming `tags` is exhaustive is wrong.

## Three front matter formats

The same project may mix: YAML uses `---`, TOML uses `+++`, JSON uses `{}`. Detection cannot key on `---` alone.

## `keywords` is dual-purpose

`keywords` may either render into HTML `<meta>` or act as a taxonomy classification, depending on site config. Treat it as a weak tag — do not give it the same weight as `tags`.

## Other

- `aliases`: `[]string`, redirect paths. **Not alias semantics** (do not confuse with Obsidian's `aliases`).
- `weight`: int, sort weight.
- `draft`: bool, draft flag → maps to ontology `status`.