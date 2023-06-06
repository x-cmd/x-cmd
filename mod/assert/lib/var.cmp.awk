BEGIN{
    STATE = 0
}

function exitnow( code ){
    EXIT_CODE = code
    exit(code)
}

function get_varname( str ){
    return substr(str, 1, index(str, "=")-1)
}

$0==""{ next; }

$0=="---"{
    STATE += 1
    next
}

(STATE==0){
    prev[get_varname($0)] = $0
    next
}

(STATE==1){
    curr[get_varname($0)] = $0
    next
}

STATE==2{
    varname = substr($0, 2)
    ignore[ varname ] = 1
    if ($0~/^\+/) {
        if (prev[varname] != "") {
            printf("Violation of [%s]: Already have: %s\n", $0, prev[varname])
            exitnow(1)
        }
        if (curr[varname] == "") {
            printf("Violation of [%s]: Don't have: %s\n", $0, prev[varname])
            exitnow(1)
        }
    } else if ($0 ~ /^-/) {
        if (prev[varname] == "") {
            printf("Violation of [%s]: Don't have: %s\n", $0, prev[varname])
            exitnow(1)
        }

        if (curr[varname] != "") {
            printf("Violation of [%s]: Still have: %s\n", $0, prev[varname])
            exitnow(1)
        }
    } else if ($0 ~/^:/ ){
        if (prev[varname] == "") {
            printf("Violation of [%s]: Don't have: %s\n", $0, prev[varname])
            exitnow(1)
        }

        if (curr[varname] == "") {
            printf("Violation of [%s]: Don't have: %s\n", $0, prev[varname])
            exitnow(1)
        }

        if (curr[varname] == prev[varname]) {
            printf("Violation of [%s]: Don't change: %s\n", $0, prev[varname])
            exitnow(1)
        }
    } else {
        next
    }
    next
}

END{
    if (EXIT_CODE == 0) {
        for (e in prev) {
            if (ignore[ e ] == 1) continue
            # print e
            if (prev[e] != curr[e]) {
                printf("Violation of [%s]: Unexpected change: \nPrev: %s\nCurr: %s\n", e, prev[e], curr[e])
                exitnow(1)
            }
        }
    
        for (e in curr) {
            if (ignore[ e ] == 1) continue
            # print e
            if (prev[e] != curr[e]) {
                printf("Violation of [%s]: Unexpected change: \nPrev: %s\nCurr: %s\n", e, prev[e], curr[e])
                exitnow(1)
            }
        }
    }
    
    exit(EXIT_CODE)
}
