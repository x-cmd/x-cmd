# card.jq - jq module for `x repo card`
#
# Library of named functions called from lib/card via `jq -L <dir>`:
#
#   card_query $o $n $searches
#       Build the GraphQL request payload (query + variables). $searches
#       is an array of search-query strings; the aliases s1..sN and the
#       matching variable declarations are generated from its length, so
#       adding a time window on the shell side needs no edit here.
#
#   card_search_counts $cnt
#       Pull the $cnt issue-search counts out of a GraphQL response as a
#       JSON array, in the same order they were passed to card_query.
#
#   card_commit_counts $wins
#       Sum commit_activity days[] for each window in $wins (a JSON array
#       of day counts). Windows longer than the endpoint's 364-day horizon
#       come back as null so the caller can fill them from REST.
#
#   card_yaml $labels $dates $counts $commits $commit_total $collected_at
#       Render the response + windowed counts as the YAML consumed by
#       card.awk. POPULARITY and TIMELINE are split out of the original
#       combined `github:` block into their own sections so the same YAML
#       can drive a future popularity-only or timeline-only view without
#       re-querying GitHub.
#
# Function names are prefixed with `card_` so they don't collide
# with anything a user might `include` into the same jq process.

# ---- card_query ----------------------------------------------------------

# The search aliases are built from $searches rather than spelled out, so
# the window set lives in exactly one place (lib/card). Each entry becomes
# a `sN:search(...)` selection plus an `$sN:String!` declaration; passing
# the strings as variables (not inlined into the query text) keeps the `>`
# in `created:>DATE` from terminating the GraphQL parse.
def card_query($o; $n; $searches):
    ($searches | to_entries)                                              as $e
    | ($e | map("$s\(.key + 1):String!") | join(","))                     as $decl
    | ($e
       | map("s\(.key + 1):search(query:$s\(.key + 1),type:ISSUE,first:0){issueCount}")
       | join(" "))                                                       as $sel
    | {
        query: (
          "query($o:String!,$n:String!,\($decl)){"
          # Static repo fields. The four aliased totalCounts (prMerged /
          # prOpen / issueOpen / issueClosed) give the all-time breakdown
          # that the `total:` YAML row reports; `pullRequests` /`issues`
          # without a state filter stay for the popularity: section.
          + "a:repository(owner:$o,name:$n){"
          + "description licenseInfo{spdxId} createdAt isArchived homepageUrl"
          + " forkCount watchers{totalCount} stargazerCount pushedAt"
          + " releases(first:100,orderBy:{field:CREATED_AT,direction:DESC}){totalCount nodes{publishedAt tagName name}}"
          + " mentionableUsers{totalCount}"
          + " issues(states:[OPEN,CLOSED]){totalCount}"
          # MERGED must be listed explicitly: a merged PR is not in the
          # CLOSED state, so [OPEN,CLOSED] silently omitted every merged
          # PR and popularity.pullRequest came out far below the sum of
          # the total: row's mergedPR + openPR.
          + " pullRequests(states:[OPEN,CLOSED,MERGED]){totalCount}"
          + " prMerged:pullRequests(states:MERGED){totalCount}"
          + " prOpen:pullRequests(states:OPEN){totalCount}"
          + " issueOpen:issues(states:OPEN){totalCount}"
          + " issueClosed:issues(states:CLOSED){totalCount}"
          + " languages(first:100){edges{size node{name}}}}"
          # defaultBranchRef is a separate aliased repository query: inlined
          # alongside the field set above it trips an undocumented GraphQL
          # cost ceiling. `history{totalCount}` (no `since:`) is the all-time
          # commit count and does work — only the `since:`-filtered form is
          # broken on GitHub's backend, which is why the windowed commit
          # counts go through REST /stats/commit_activity instead.
          + "b:repository(owner:$o,name:$n){defaultBranchRef{target{... on Commit{oid committedDate history{totalCount}}}}} "
          + $sel
          + "}"
        ),
        variables: (
          { o: $o, n: $n }
          + ($e | map({ key: "s\(.key + 1)", value: .value }) | from_entries)
        )
      };

# ---- card_search_counts --------------------------------------------------

# Read back the $cnt search aliases as a JSON array, in alias order. The
# caller passes the whole array on to card_yaml via --argjson, so no
# per-value shell variables and no line-by-line `read` loop.
def card_search_counts($cnt):
    .data as $d
    | [ range(0; $cnt) | $d["s\(. + 1)"].issueCount // 0 ];

# ---- card_commit_counts --------------------------------------------------

# /stats/commit_activity returns 52 weeks × 7 days = up to 364 daily
# counts (no zero-padding for weeks with no activity). Sum the tail of
# the flattened array for each window in $wins.
#
# Windows longer than what the endpoint covers yield null, not a sum: a
# 720-day window answered with the 364-day total would silently understate
# by up to half. The caller detects the null and fetches that window from
# REST /commits?since= instead.
#
# Tolerate non-array responses: GitHub returns `{}` while the stats job
# is still computing, and `{"message":"Not Found",...}` (HTTP 404) for
# archived / fork / blocked repos. Either shape used to crash here with
# "Cannot index string with string 'days'" because `[.[].days]` blindly
# tried `.days` on each value of the response object. Coerce non-arrays
# to `[]`, and filter out entries whose `.days` isn't an array of ints.
#
# `(add // [])` must stay parenthesized: jq 1.7 binds `X // Y as $v | body`
# differently from jq 1.8, and the unparenthesized form silently emitted the
# flattened day array instead of the sums — which then reached the caller's
# `--argjson` as invalid JSON. GitHub runners ship jq 1.7.x, so this is the
# version that matters in CI.
def card_commit_counts($wins):
    (if type == "array" then . else [] end) as $arr
    | [ $arr[]
        | select(type == "object" and (.days | type == "array"))
        | .days
      ] as $per_week
    | (($per_week | add) // []) as $total
    | ($total | length) as $len
    | [ $wins[]
        | if . > 364 then null
          else ($total[$len - . :] // [] | add // 0)
          end
      ];

# ---- card_yaml -----------------------------------------------------------

# Render a YAML block per section. Sections in the order they're emitted:
#   github:     description / license / homepage / archived
#   timeline:   created / lastCommit / lastRelease / latestVersion
#   popularity: star / watcher / fork / release / contributor /
#               pullRequest / issue
#   language:   sorted by size desc; totalBytes appended (sum of language
#               bytes — matches GitHub's LanguageEdge.size unit)
#   recent:     one sub-block per window label in $labels, each with
#               since / release / mergedPR / openPR / closedIssue /
#               openIssue / commit
#   total:      the same six metrics over the repo's whole history
#   collectedAt (top-level, not a section)
#
# $counts is a flat array of 4 × W search counts laid out metric-major:
# mergedPR for every window, then openPR, then closedIssue, then openIssue.
# $commits is W commit counts. Both are indexed off $labels' length, so the
# window set can grow without touching this signature.
def card_yaml($labels; $dates; $counts; $commits; $commit_total; $collected_at):

    # YAML output policy:
    # - description is emitted as a literal block scalar (`|`). jq strings
    #   can contain `\n`, `:`, `"`, `?` — any of those breaks a bare scalar
    #   AND requires ugly backslash escaping in a double-quoted form. A
    #   literal block preserves the newlines exactly and never interprets
    #   a single character, so no escaping is needed.
    # - Other short string fields (license, homepage, head, dates, version,
    #   collectedAt) are bare scalars — they don't contain `:` or `?` in
    #   practice (spdxId, dates, hex SHAs).
    # - Missing values render as empty after the colon (which the parser
    #   reads as null, distinct from "?" or `"?"`).
    # - Numeric fields stay unquoted so downstream can compare / sum.
    #
    # literal: stream a YAML literal block (`|`) for the current string.
    # Comma-separated outputs (`header_line, content_lines...`) so each
    # emits as a separate document line. Empty / null -> just the header
    # with one indented space; the parser reads that as an empty string.
    def literal:
        if . == null or . == "" then "  |", "    "
        else "  |", (. | split("\n") | .[] | "    " + .)
        end;

    ($labels | length) as $W
    | .data.a as $r
    | (.data.b.defaultBranchRef // {}) as $branch
    | ($branch.target // {}) as $head
    | ($r.releases.nodes // []) as $rel
    | "about:",
      "  description:",
      ($r.description // "" | . | literal),
      "  license: \($r.licenseInfo.spdxId // "NOASSERTION")",
      "  homepage: \($r.homepageUrl // "")",
      "  head: \($head.oid[:7] // "")",
      "  archived: \($r.isArchived // false)",
      "  latestVersion: \($rel[0].tagName // $rel[0].name // "")",
      "  collectedAt: \($collected_at)",
      "timeline:",
      "  created: \($r.createdAt[:10] // "")",
      "  lastCommit: \($head.committedDate[:10] // "")",
      "  lastRelease: \($rel[0].publishedAt[:10] // "")",
      "popularity:",
      "  star: \($r.stargazerCount // 0)",
      "  watcher: \($r.watchers.totalCount // 0)",
      "  fork: \($r.forkCount // 0)",
      "  release: \($r.releases.totalCount // 0)",
      "  contributor: \($r.mentionableUsers.totalCount // 0)",
      "  pullRequest: \($r.pullRequests.totalCount // 0)",
      "  issue: \($r.issues.totalCount // 0)",
      (if ($r.languages.edges // [] | length) > 0
       then "language:",
            ($r.languages.edges // [] | sort_by(-.size)[] | "  \(.node.name): \(.size)"),
            ($r.languages.edges // [] | map(.size) | add | "totalBytes: \(.)")
       else empty end),
      "recent:",
      ( range(0; $W) as $i
        # Release counts are derived here rather than searched for: the
        # `releases(first:100)` node list already carries publishedAt, so
        # filtering it client-side costs nothing. Caveat: a repo with more
        # than 100 releases inside a window undercounts — the long windows
        # (360d / 720d) are the ones exposed to that.
        | "  \($labels[$i]):",
          "    since: \($dates[$i])",
          "    release: \($rel | map(select(.publishedAt[:10] >= $dates[$i])) | length)",
          "    mergedPR: \($counts[$i])",
          "    openPR: \($counts[$W + $i])",
          "    closedIssue: \($counts[2 * $W + $i])",
          "    openIssue: \($counts[3 * $W + $i])",
          "    commit: \($commits[$i] // 0)"
      ),
      "total:",
      "  release: \($r.releases.totalCount // 0)",
      "  mergedPR: \($r.prMerged.totalCount // 0)",
      "  openPR: \($r.prOpen.totalCount // 0)",
      "  closedIssue: \($r.issueClosed.totalCount // 0)",
      "  openIssue: \($r.issueOpen.totalCount // 0)",
      "  commit: \($head.history.totalCount // $commit_total // 0)",
      (if (.errors // [] | length) > 0
       then "graphqlErrors:",
            (.errors | .[] | "  - \(.message // "?")")
       else empty end);
