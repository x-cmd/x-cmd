
function handle( varname, param,    t ){
    param = sprintf("${%s+%s} ", varname, shqu(param) )
    t = sprintf("%s=%s", varname, ("\"$" varname "\"") )
    return param sprintf("${%s+%s}", varname, t )
}

BEGIN{
    argl = str_split(ENVIRON[ "data" ], arg, "\001")

    # code = data = ""
    for (i=1; i<=argl; ++i) {
        if ( arg[i] == "--" ) {
            for (j=i+1; j<=argl; ++j) data = data " " shqu1(arg[j])
            code = code " "  sprintf("--data-raw \"$( x jo dict %s ;)\"", data)
            break
        }

        if ( arg[i] == "@-" ) {
            code = code " -d @-"
            break
        }

        if ( match(arg[i], /^[^:]+:/) ) {
            name = substr( arg[i], 1, RLENGTH-1 )
            value = substr( arg[i], RLENGTH + 1 )
            if (value == "")    code = code " " handle(name, "-H")
            else                code = code " -H " shqu(sprintf("%s:%s", name, value))
            continue
        }

        if ( match(arg[i], /^[^=]+==/) ) {
            name = substr( arg[i], 1, RLENGTH-2 )
            value = substr( arg[i], RLENGTH + 1 )
            if (value == "")    code = code " " handle(name, "--data-urlencode")
            else                code = code " " sprintf("--data-urlencode %s=%s", name, shqu(value))
            continue
        }

        if (arg[i] ~ /^(https|http):/) { code = code " " shqu(arg[i]); continue; }


        if ( match(arg[i], /^[^=]+=/) ) {
            name = substr( arg[i], 1, RLENGTH-1 )
            value = substr( arg[i], RLENGTH + 1 )
            if (value == "")    code = code " " handle(name, "--form")
            else                code = code " " sprintf("--form %s=%s", name, shqu(value))
            continue
        }

        if ( arg[i] ~ "^-[a-zA-Z]+$") {
            code = code " " arg[i]
            continue
        }

        if ( arg[i] != "") code = code " -d " "\"$" arg[i] "\""
    }

    print code ;
}


