#!/usr/bin/awk -f
# eget lsassetmap — TSV → YAML reshape.
#
# Input: the TSV stream produced by ___x_cmd_eget_subcmd_lsassetmap___tsv.
#   Header line:
#     platform\tname\turl\tsize\tscore
#   6 data rows, one per platform (fixed order: darwin/{arm64,amd64},
#   linux/{arm64,amd64}, win/{arm64,amd64}). Empty asset rows (no
#   candidate cleared THRESHOLD) emit only the platform column.
#
# Output: a YAML document wrapped under an `eget:` parent so it slots
# in cleanly as a 4th segment of latest.card.yml (sibling to
# `about:`, `timeline:`, `scorecard:`). Schema:
#
#   eget:
#     collectedAt: 2026-09-07T12:34:56Z
#     platform:                       # singular, not `platforms`
#       darwin/arm64:
#         name:  foo-1.0-darwin-arm64.tar.gz
#         url:   https://...
#         size:  1234567
#         score: 45
#       darwin/amd64:
#         name:  null                  # no asset designed for this
#         url:   null                  # platform — gap signal for
#         size:  null                  # the stat consumer
#         score: null
#       ...
#
# Why singular `platform:` not `platforms:`: matches the column name
# in the input TSV (`platform\tname\t...`), and the input is already
# keyed by platform — no need to pluralize the wrapper.
#
# Run as: awk -f lsassetmap_yml.awk

NR == 1 {
    # Header row — emit the wrapper here, then continue so we don't
    # treat "platform" as a data row.
    if ($1 == "platform") {
        print "eget:"
        # AWK_COLLECTED_AT is passed via `-v` by lib/main so daily-batch
        # runs get a single consistent timestamp for the whole 4th
        # segment. Default to the epoch so an unrun awk (e.g. ad-hoc
        # test) still emits a parseable, obviously-wrong value rather
        # than a missing field.
        ts = AWK_COLLECTED_AT
        if (ts == "") ts = "1970-01-01T00:00:00Z"
        print "  collectedAt: " ts
        print "  platform:"
        next
    }
}

NF == 0 { next }

{
    plat = $1
    name = $2
    url  = $3
    sz   = $4
    sc   = $5

    print "    " plat ":"
    if (name == "") {
        print "      name:  null"
        print "      url:   null"
        print "      size:  null"
        print "      score: null"
    } else {
        print "      name:  " name
        print "      url:   " url
        print "      size:  " sz
        print "      score: " sc
    }
}
