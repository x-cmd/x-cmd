function get_varname( str ){
    return substr(str, 1, index(str, "=")-1)
}

function skip_var( data,  n ){
    n = get_varname( data )

    # Skip by prefix patterns (fast path - filters most variables)
    # [_'\-0-9@]     : invalid chars (_, -, ', digits, @)
    # (ZSH|zsh|BASH|DASH|ASH|KASH)_ : shell-specific prefixes
    # x_exectime_    : x-cmd internal timing
    if (n ~ /^[_'\-0-9@]/) return 1
    # Skip by shell-specific prefixes
    if (n ~ /^(ZSH|zsh|ZLS|zle|ZLE|zls|ZFTP|zftp|BASH|DASH|ASH|KASH|x|X)_/) return 1

    # Skip exact variable names (shell dynamic/special variables)
    if (n == "FUNCNAME")        return 1
    if (n == "PPID")            return 1
    if (n == "SHLVL")           return 1
    if (n == "HISTCMD")         return 1
    if (n == "SECONDS")         return 1
    if (n == "TTYIDLE")         return 1
    if (n == "EPOCHREALTIME")   return 1
    if (n == "EPOCHSECONDS")    return 1
    if (n == "epochtime")       return 1
    if (n == "RANDOM")          return 1
    if (n == "SRANDOM")         return 1
    if (n == "ZDOTDIR")         return 1
    if (n == "KEYMAP")          return 1
    if (n == "WIDGET")          return 1
    if (n == "LASTWIDGET")      return 1
    if (n == "ERRNO")           return 1
    if (n == "LINENO")          return 1
    if (n == "COLUMNS")         return 1
    if (n == "LINES")           return 1
    if (n == "POSIXLY_CORRECT") return 1
    if (n == "PIPESTATUS")      return 1
    if (n == "PROMPT_COMMAND")  return 1
    if (n == "main")            return 1

    return 0
}

function output( data ){
    if ( skip_var( data ) == 1 ) return
    printf("%s\n", data)
}

BEGIN {
    STATE = 0
}

{
    if (STATE == 1) {
        data = data "\001\002\003" $0
    } else {
        data = $0
        # Skip lines without '=' (e.g., dynamic variables like zsh EPOCHREALTIME, EPOCHSECONDS)
        if (data !~ "=") {
            STATE = 0
            next
        }

        if ( data ~ /^zzzzzzzzzzzzzzzzzzzzzzzzzzzz=/)   exit 0
        if (data ~ /^[A-Za-z0-9_]+=$/) {
            STATE = 0
            output( data )
            next
        }

        if (data ~ /^[A-Za-z0-9_]+=[^']/) {
            STATE = 0
            output( data )
            next
        }

        if (data ~ /^[A-Za-z0-9_]+='/) {
            STATE = 1
        }
    }

    # Check for complete single-quoted variable (ends with ')
    if (data ~ /^[A-Za-z0-9_]+='([^']|('\\''))*'$/) {
        STATE = 0
        output( data )
        next
    }
}
