def loc_rows:
    (to_entries | map(select(.key != "Total")))
    | sort_by(-.value.code)[]
    | "  \(.key):",
      "    code: \(.value.code // 0)",
      "    comments: \(.value.comments // 0)",
      "    blanks: \(.value.blanks // 0)",
      "    files: \(.value.reports | length)";

def loc_file_count:
    [ to_entries[] | select(.key != "Total") | .value.reports | length ] | add // 0;

def loc_yaml($path; $collected_at; $stale):
    "path: \($path)",
    "collectedAt: \($collected_at)",
    (if $stale then "stale: true" else empty end),
    "loc:",
    loc_rows,
    "total:",
    "  code: \(.Total.code // 0)",
    "  comments: \(.Total.comments // 0)",
    "  blanks: \(.Total.blanks // 0)",
    "  files: \(loc_file_count)";

def loc_yaml_embed($path; $stale):
    "loc:",
    loc_rows,
    "locTotal:",
    "  code: \(.Total.code // 0)",
    "  comments: \(.Total.comments // 0)",
    "  blanks: \(.Total.blanks // 0)",
    "  files: \(loc_file_count)",
    "locPath: \($path)",
    (if $stale then "locStale: true" else empty end);
