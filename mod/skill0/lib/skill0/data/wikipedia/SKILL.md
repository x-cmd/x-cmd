---
name: wikipedia
description: |
  Search and read Wikipedia via x wkp — MediaWiki API, no API key,
  zero install; query, extract, suggest, and DDG route in one module.
  Load for wiki, wikipedia, encyclopedia lookup, article summary.

metadata:
  version: "0.1.0"
  category: "reference"
  tags: "wikipedia,wiki,encyclopedia,reference,lookup"
  repository: "https://github.com/x-cmd/skill0"
  type: "skill0"
  x-cmd-mod: "wkp"
  upstream: "https://en.wikipedia.org/w/api.php"
---

# wikipedia — skill0

Output is a plain-text extract (~first paragraph + infobox). Subcommand verb picks the shape — `hop` for search-then-summary, `extract` for known titles, `search` for candidates, `suggest` for did-you-mean. Default site is English Wikipedia; `--lang` / `--api-url` switch to other wikis.

## Quick Start with `x wkp`

```bash
x wkp hop Python                      # search + first-result extract in one shot
x wkp extract OpenAI                  # summary of a known page
x wkp search "Linux kernel"           # list candidates when title is uncertain
x wkp suggest pythen                  # did-you-mean: correction hints before search
```

`x wkp -h` for all flags and subcommands.

## Data and adjacent tools

Upstream: `https://en.wikipedia.org/w/api.php` — MediaWiki action API. Sister projects (Wikidata, Wiktionary, Commons) are reachable the same way; point `--api-url` at the relevant subdomain.

For the questions that go one hop beyond a wikitext summary:
- `x wkp : <query>` / `x wkp ddgo <query>` — same `x wkp` module, routed via DuckDuckGo's Wikipedia index (handles ambiguous or colloquial queries better than title search)
- `x ddgo <query>` — general web search, useful when Wikipedia has no article but the topic exists on the open web
- See the [knowledge](../knowledge/SKILL.md) skill for the broader `x hn` / `x rfc` / `x se` research toolkit
- `x wkp open <page>` — fall back to the browser when you actually need the rendered page (infoboxes, tables, images)
