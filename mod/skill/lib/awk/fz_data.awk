BEGIN {
    FS = "\t"

    # Color definitions
    fmt_zero    = prepare_fmt( "\033[0;2m" )
    fmt_new     = prepare_fmt( "\033[0;2;36m" )
    fmt_cold    = prepare_fmt( "\033[0;36m" )
    fmt_cool    = prepare_fmt( "\033[0;32m" )
    fmt_warm    = prepare_fmt( "\033[0;33m" )
    fmt_hot     = prepare_fmt( "\033[0;31m" )
    fmt_smoke   = prepare_fmt( "\033[0;1;31m" )
}

function prepare_fmt( pop_fmt,     fmt ){
    fmt = ""
    fmt = fmt pop_fmt "%-3s "           # Emoji indicator
    fmt = fmt "%-32s" "\033[0m"         # Name
    fmt = fmt "\033[0;35m" "%-12s\t"    # Author
    fmt = fmt "\033[0m" "%-60s"         # Description
    fmt = fmt "\033[0;2m" "%-12s\t"     # License
    fmt = fmt pop_fmt "%-8s\033[0m\n"   # ID

    return fmt
}

{
    if (NR == 1) {
        # Skip header
        next
    }

    id      = $1
    url     = $2
    reference = $3
    license = $4
    name    = $5
    author  = $6
    description = $7

    # Determine formatting based on author/usage patterns
    _fmt = fmt_cool
    _emo = "🔧"

    # Color coding based on author
    if (author == "Anthropic") {
        _fmt = fmt_smoke
        _emo = "⭐"
    } else if (author == "K-Dense-AI") {
        _fmt = fmt_warm
        _emo = "🧪"
    } else if (description ~ /scientific|research|bio/) {
        _fmt = fmt_cold
        _emo = "🔬"
    } else if (description ~ /document|office|pdf/) {
        _fmt = fmt_cool
        _emo = "📄"
    } else if (description ~ /art|design|visual/) {
        _fmt = fmt_warm
        _emo = "🎨"
    } else if (description ~ /integration|api|tool/) {
        _fmt = fmt_cold
        _emo = "🔌"
    }

    # Truncate long descriptions for better display
    if (length(description) > 60) {
        description = substr(description, 1, 57) "..."
    }

    printf( _fmt, _emo, name, author, description, license, id )
}