function get_varname( str ){
    return substr(str, 1, index(str, "=")-1)
}

function skip_var( data,  n ){
    n = get_varname( data )
    if ( n == "FUNCNAME")                       return 1
    if ( n == "BASH_LINENO")                    return 1
    if ( n == "_")                              return 1
    if ( n == "ZSH_EVAL_CONTEXT")               return 1
    if ( n == "HISTCMD")                        return 1
    if ( n == "SECONDS")                        return 1

    if ( n == "BASH_COMMAND")                   return 1
    if ( n == "PROMPT_COMMAND")                 return 1

    # if ( n ~ "^__vsc")                          return 1
    if ( n ~ "^__vsc")                          return 1


    # vscode env
    if ( n == "main")                           return 1

    # TODO: add more variables to ignore...

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
        data = data "\n" $0
    } else {
        data = $0
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
    }
    # ^[A-Za-z0-9_]+='[^'\\]*(((\\\\)|(\\'))*[^']*)*'$
    if (data ~ /^[A-Za-z0-9_]+='([^'\\]*(\\\\|\\')*[^']*)'$/) {
        STATE = 0
        gsub("\n", "\001\002\003", data)
        output( data )
    }

    if(data ~ /(^[-'0-9@_\\].*)|(^ZSH_.*)|(^zsh_.*)|(^BASH_.*)|(^DASH_.*)|(ASH_.*)|(^KASH_.*) /){
            STATE = 0
            next
    }else {
        STATE = 1
    }
}