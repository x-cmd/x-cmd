# card.jq - jq module for `x repo card`
#
# Library of named functions called from lib/card via `jq -f card.jq`:
#
#   card_query $o $n $s1 .. $s16
#       Build the GraphQL request payload (query + variables).
#
#   card_search_counts
#       Pull the 16 issue-search counts out of a GraphQL response,
#       one per line in a fixed order.
#
#   card_commit_counts
#       Sum the last 30/90/180/360 days of commit_activity days[]
#       into 4 lines.
#
#   card_yaml $merged30 .. $collected_at
#       Render the response + windowed counts as the YAML consumed
#       by card.awk. POPULARITY and TIMELINE are split out of the
#       original combined `github:` block into their own sections
#       so the same YAML can drive a future popularity-only or
#       timeline-only view without re-querying GitHub.
#
# Function names are prefixed with `card_` so they don't collide
# with anything a user might `include` into the same jq process.

# ---- card_query ----------------------------------------------------------

def card_query($o; $n;
               $s1;  $s2;  $s3;  $s4;
               $s5;  $s6;  $s7;  $s8;
               $s9;  $s10; $s11; $s12;
               $s13; $s14; $s15; $s16):
    {
      query: "query($o:String!,$n:String!,$s1:String!,$s2:String!,$s3:String!,$s4:String!,$s5:String!,$s6:String!,$s7:String!,$s8:String!,$s9:String!,$s10:String!,$s11:String!,$s12:String!,$s13:String!,$s14:String!,$s15:String!,$s16:String!){a:repository(owner:$o,name:$n){description licenseInfo{spdxId} createdAt isArchived homepageUrl forkCount watchers{totalCount} stargazerCount pushedAt releases(first:100,orderBy:{field:CREATED_AT,direction:DESC}){totalCount nodes{publishedAt tagName name}} mentionableUsers{totalCount} issues(states:[OPEN,CLOSED]){totalCount} pullRequests(states:[OPEN,CLOSED]){totalCount} languages(first:100){edges{size node{name}}}} b:repository(owner:$o,name:$n){defaultBranchRef{target{... on Commit{oid committedDate}}}} m30:search(query:$s1,type:ISSUE,first:0){issueCount} m90:search(query:$s2,type:ISSUE,first:0){issueCount} m180:search(query:$s3,type:ISSUE,first:0){issueCount} m360:search(query:$s4,type:ISSUE,first:0){issueCount} op30:search(query:$s5,type:ISSUE,first:0){issueCount} op90:search(query:$s6,type:ISSUE,first:0){issueCount} op180:search(query:$s7,type:ISSUE,first:0){issueCount} op360:search(query:$s8,type:ISSUE,first:0){issueCount} ci30:search(query:$s9,type:ISSUE,first:0){issueCount} ci90:search(query:$s10,type:ISSUE,first:0){issueCount} ci180:search(query:$s11,type:ISSUE,first:0){issueCount} ci360:search(query:$s12,type:ISSUE,first:0){issueCount} oi30:search(query:$s13,type:ISSUE,first:0){issueCount} oi90:search(query:$s14,type:ISSUE,first:0){issueCount} oi180:search(query:$s15,type:ISSUE,first:0){issueCount} oi360:search(query:$s16,type:ISSUE,first:0){issueCount}}",
      variables: {
        o: $o, n: $n,
        s1:  $s1,  s2:  $s2,  s3:  $s3,  s4:  $s4,
        s5:  $s5,  s6:  $s6,  s7:  $s7,  s8:  $s8,
        s9:  $s9,  s10: $s10, s11: $s11, s12: $s12,
        s13: $s13, s14: $s14, s15: $s15, s16: $s16
      }
    };

# ---- card_search_counts --------------------------------------------------

# 16 search aliases in fixed order: merged{30,90,180,360}, openpr{30,...},
# closei{30,...}, openi{30,...}. Caller reads them with `read -r` into
# local shell variables in the same order.
def card_search_counts:
    [
      .data.m30.issueCount  // 0,
      .data.m90.issueCount  // 0,
      .data.m180.issueCount // 0,
      .data.m360.issueCount // 0,
      .data.op30.issueCount // 0,
      .data.op90.issueCount // 0,
      .data.op180.issueCount // 0,
      .data.op360.issueCount // 0,
      .data.ci30.issueCount // 0,
      .data.ci90.issueCount // 0,
      .data.ci180.issueCount // 0,
      .data.ci360.issueCount // 0,
      .data.oi30.issueCount // 0,
      .data.oi90.issueCount // 0,
      .data.oi180.issueCount // 0,
      .data.oi360.issueCount // 0
    ] | .[] | tostring;

# ---- card_commit_counts --------------------------------------------------

# /stats/commit_activity returns 52 weeks × 7 days = up to 364 daily
# counts (no zero-padding for weeks with no activity). Sum the tail of
# the flattened array for 30/90/180/360-day windows.
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
# flattened day array instead of the four sums — which then reached the
# caller's `--argjson` as invalid JSON. GitHub runners ship jq 1.7.x, so this
# is the version that matters in CI.
def card_commit_counts:
    (if type == "array" then . else [] end) as $arr
    | [ $arr[]
        | select(type == "object" and (.days | type == "array"))
        | .days
      ] as $per_week
    | (($per_week | add) // []) as $total
    | ($total | length) as $len
    | [
        ($total[$len -  30 :] // [] | add // 0),
        ($total[$len -  90 :] // [] | add // 0),
        ($total[$len - 180 :] // [] | add // 0),
        ($total[$len - 360 :] // [] | add // 0)
      ] | .[] | tostring;

# ---- card_yaml -----------------------------------------------------------

# Render a YAML block per section. Sections in the order they're emitted:
#   github:     description / license / homepage / archived
#   timeline:   created / lastCommit / lastRelease / latestVersion
#   popularity: star / watcher / fork / release / contributor /
#               pullRequest / issue
#   language:   sorted by size desc; totalBytes appended (sum of language
#               bytes — matches GitHub's LanguageEdge.size unit)
#   detail:     head
#   recent:     last{30,90,180,360}d × {since, release, mergedPR,
#               openPR, closedIssue, openIssue, commit}
#   collectedAt (top-level, not a section)
def card_yaml($merged30;  $merged90;  $merged180;  $merged360;
              $openpr30;  $openpr90;  $openpr180;  $openpr360;
              $closei30;  $closei90;  $closei180;  $closei360;
              $openi30;   $openi90;   $openi180;   $openi360;
              $commit30;  $commit90;  $commit180;  $commit360;
              $date30;    $date90;    $date180;    $date360;
              $days90;    $collected_at):

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

    .data.a as $r
    | (.data.b.defaultBranchRef // {}) as $branch
    | ($branch.target // {}) as $head
    | ($r.releases.nodes // [] | map(select(.publishedAt[:10] >= $date30 )) | length) as $release30
    | ($r.releases.nodes // [] | map(select(.publishedAt[:10] >= $date90 )) | length) as $release90
    | ($r.releases.nodes // [] | map(select(.publishedAt[:10] >= $date180)) | length) as $release180
    | ($r.releases.nodes // [] | map(select(.publishedAt[:10] >= $date360)) | length) as $release360
    | "about:",
      "  description:",
      ($r.description // "" | . | literal),
      "  license: \($r.licenseInfo.spdxId // "NOASSERTION")",
      "  homepage: \($r.homepageUrl // "")",
      "  head: \($head.oid[:7] // "")",
      "  archived: \($r.isArchived // false)",
      "  latestVersion: \($r.releases.nodes[0].tagName // $r.releases.nodes[0].name // "")",
      "  collectedAt: \($collected_at)",
      "timeline:",
      "  created: \($r.createdAt[:10] // "")",
      "  lastCommit: \($head.committedDate[:10] // "")",
      "  lastRelease: \($r.releases.nodes[0].publishedAt[:10] // "")",
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
      "  last30d:",
      "    since: \($date30)",
      "    release: \($release30)",
      "    mergedPR: \($merged30)",
      "    openPR: \($openpr30)",
      "    closedIssue: \($closei30)",
      "    openIssue: \($openi30)",
      "    commit: \($commit30)",
      "  last\($days90)d:",
      "    since: \($date90)",
      "    release: \($release90)",
      "    mergedPR: \($merged90)",
      "    openPR: \($openpr90)",
      "    closedIssue: \($closei90)",
      "    openIssue: \($openi90)",
      "    commit: \($commit90)",
      "  last180d:",
      "    since: \($date180)",
      "    release: \($release180)",
      "    mergedPR: \($merged180)",
      "    openPR: \($openpr180)",
      "    closedIssue: \($closei180)",
      "    openIssue: \($openi180)",
      "    commit: \($commit180)",
      "  last360d:",
      "    since: \($date360)",
      "    release: \($release360)",
      "    mergedPR: \($merged360)",
      "    openPR: \($openpr360)",
      "    closedIssue: \($closei360)",
      "    openIssue: \($openi360)",
      "    commit: \($commit360)",
      (if (.errors // [] | length) > 0
       then "graphqlErrors:",
            (.errors | .[] | "  - \(.message // "?")")
       else empty end);