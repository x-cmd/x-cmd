# ghclaw events timeline processor — one awk pass over the events body
#
# stdin : one-line JSON array of GitHub events (newest first, as returned by
#         /repos/{owner}/{repo}/events and /orgs/{org}/events)
# -v target     : target being watched (<owner>/<repo> or <org>) — for logs
# -v mqfp       : MQ.tsv file — one TSV line per NEW event:
#                 created_at \t id \t type \t action \t repo \t actor \t number \t title \t detail
#                 (title: issue/discussion title or release name; empty when the
#                 payload has none — notably PullRequestEvent's shallow payload
#                 has no title. detail: per-type discriminating info)
#                 full data is NOT duplicated here — reverse-lookup the event
#                 file: <data-dir>/<repo>/<type>.<id>.json
# -v current_id : cursor event id ("" on first boot)
# -v dir        : shared data root — event files land at dir/<repo>/<type>.<id>.json
#                 (repo sharding from the event's repo.name; shared across
#                 targets, event ids are globally unique)
# -v cursor_fp  : cursor file — rewritten with the newest event id
#
# logs (log_info / log_warn from core.awk):
#   first boot -> "[LISTEN] initialized cursor for <target> at id <id>"
#   cursor gap -> "[LISTEN] cursor gap for <target> — events lost since id <id>"
#
# side effects: writes dir/<type>.<id>.json (pretty json of the event),
#               appends the index line to mqfp, advances cursor_fp

# unquote a JSON string token. Non-string tokens pass through: "null" -> ""
# (juq assumes quotes and would mangle them — null becomes "ul"); numbers
# and true/false are returned as-is.
function ujq(v){
    if (v == "" || v == "null")   return ""
    if (v !~ "^\"")               return v
    return juq(v)
}

# event id normalization: always an integer token from GitHub, but stay safe
function eid(v){ if (v ~ "^\"") v = juq(v); return sprintf("%.0f", v + 0) }

{ jiparse_after_tokenize(o, $0) }

END{
    AKP = SUBSEP "\"1\""               # the events array keypath (single top-level array)
    al  = o[ AKP L ]
    if (al == "")            exit 0          # not an array / empty timeline
    newest = eid(o[ AKP SUBSEP "\"1\"", "\"id\"" ])

    # first boot: record cursor only, do not replay history
    if (current_id == "") {
        printf "%s\n", newest > cursor_fp
        close(cursor_fp)

        log_info( "ghclaw", "[LISTEN] initialized cursor for " target " at id " newest )
        exit 0
    }

    seen = 0
    for (i=1; i<=al; ++i) {
        kp = AKP SUBSEP "\"" i "\""
        id = eid(o[ kp, "\"id\"" ])
        if (id == current_id) { seen = 1; break }

        etype  = ujq(o[ kp, "\"type\"" ])
        action = ujq(o[ kp, "\"payload\"", "\"action\"" ])
        repo   = ujq(o[ kp, "\"repo\"", "\"name\"" ])

        number = o[ kp, "\"payload\"", "\"issue\"", "\"number\"" ]
        if (number == "")   number = o[ kp, "\"payload\"", "\"pull_request\"", "\"number\"" ]
        if (number == "")   number = o[ kp, "\"payload\"", "\"number\"" ]

        mkdirp( dir "/" repo )
        fp = dir "/" repo "/" etype "." id ".json"
        print jstr(o, kp) > fp
        close(fp)

        # column 8 — subject title (triage/notification context); PR payloads
        # are shallow and carry none
        title = ujq(o[ kp, "\"payload\"", "\"issue\"", "\"title\"" ])
        if (title == "")   title = ujq(o[ kp, "\"payload\"", "\"discussion\"", "\"title\"" ])
        if (title == "")   title = ujq(o[ kp, "\"payload\"", "\"release\"", "\"name\"" ])
        gsub(/[[:space:]]+/, " ", title)

        # column 9 — per-type discriminating detail, so the queue row reads
        # as a full story without opening the event file
        detail = ""
        if (etype == "PushEvent") {
            detail = ujq(o[ kp, "\"payload\"", "\"ref\"" ])
            sub(/^refs\/heads\//, "", detail)
            sub(/^refs\/tags\//,  "tag:", detail)
        } else if (etype == "CreateEvent" || etype == "DeleteEvent") {
            detail = "ref:"  ujq(o[ kp, "\"payload\"", "\"ref\"" ])      \
                     ",type:" ujq(o[ kp, "\"payload\"", "\"ref_type\"" ])
        } else if (etype == "PullRequestReviewEvent") {
            detail = "state:" ujq(o[ kp, "\"payload\"", "\"review\"", "\"state\"" ])
        } else if (etype == "PullRequestReviewCommentEvent") {
            detail = "path:" ujq(o[ kp, "\"payload\"", "\"comment\"", "\"path\"" ])
        } else if (etype == "ReleaseEvent") {
            detail = "tag:" ujq(o[ kp, "\"payload\"", "\"release\"", "\"tag_name\"" ])
        } else if (etype == "GollumEvent") {
            detail = "page:" ujq(o[ kp, "\"payload\"", "\"pages\"", "\"1\"", "\"page_name\"" ])
        } else if (etype == "PullRequestEvent") {
            detail = ujq(o[ kp, "\"payload\"", "\"pull_request\"", "\"head\"", "\"ref\"" ]) "->" \
                     ujq(o[ kp, "\"payload\"", "\"pull_request\"", "\"base\"", "\"ref\"" ])
        } else if (action == "labeled" || action == "unlabeled") {
            detail = "label:" ujq(o[ kp, "\"payload\"", "\"label\"", "\"name\"" ])
        } else if (action == "assigned") {
            detail = "assignee:" ujq(o[ kp, "\"payload\"", "\"assignee\"", "\"login\"" ])
        } else if (etype == "MemberEvent") {
            detail = "member:" ujq(o[ kp, "\"payload\"", "\"member\"", "\"login\"" ])
        } else if (etype == "ForkEvent") {
            detail = "to:" ujq(o[ kp, "\"payload\"", "\"forkee\"", "\"full_name\"" ])
        } else if (etype == "DiscussionEvent") {
            detail = "disc:" ujq(o[ kp, "\"payload\"", "\"discussion\"", "\"title\"" ])
        } else if (etype == "CommitCommentEvent") {
            detail = "commit:" substr(ujq(o[ kp, "\"payload\"", "\"comment\"", "\"commit_id\"" ]), 1, 7)
        }
        # Variable trailing columns (from col 10, per type; body is always
        # the LAST column) — consumers can coarse-filter from the line alone
        # without reverse-looking-up the event file
        extra = ""
        if (etype == "IssueCommentEvent" || etype == "PullRequestReviewCommentEvent" || etype == "CommitCommentEvent") {
            # comment types: detail keeps discriminators only; body/comment
            # id move to the trailing columns
            body = ujq(o[ kp, "\"payload\"", "\"comment\"", "\"body\"" ])
            gsub(/[[:space:]]+/, " ", body)
            extra = eid(o[ kp, "\"payload\"", "\"comment\"", "\"id\"" ]) "\t" body
        } else if (etype == "IssuesEvent") {
            body = ujq(o[ kp, "\"payload\"", "\"issue\"", "\"body\"" ])
            gsub(/[[:space:]]+/, " ", body)
            extra = body
        }
        # a comment on a PR is routed differently from one on a plain issue
        if (etype == "IssueCommentEvent" && o[ kp, "\"payload\"", "\"issue\"", "\"pull_request\"" ] != "")
            detail = detail ",pr"

        printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s%s\n",            \
               ujq(o[ kp, "\"created_at\"" ]), id, etype, action,  \
               repo, ujq(o[ kp, "\"actor\"", "\"login\"" ]), \
               number, title, detail, (extra == "") ? "" : "\t" extra >> mqfp
    }
    close(mqfp)

    if (!seen)  {
        log_warn( "ghclaw", "[LISTEN] cursor gap for " target " — events lost since id " current_id )
    }

    printf "%s\n", newest > cursor_fp
    close(cursor_fp)
}
