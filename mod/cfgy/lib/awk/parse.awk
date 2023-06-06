{
    jiparse( o, $0 )
}

BEGIN{
    if (prefix == "") prefix = "___X_CMD_cfgy"

    CODE_LOCAL  = ""
    CODE_UNSET  = ""
    CODE_EQ =   ""

    CODE_NMAP   = ""
}

function put_nmap( name, id ){
    CODE_NAME = CODE_NAME "x sdict put " prefix "_nmap " shqu(name) " " id "\n"
}

function p(var, val){
    CODE_LOCAL  = CODE_LOCAL " local " var         "\n"
    CODE_UNSET  = CODE_UNSET " unset " var         " ;"
    CODE_EQ     = CODE_EQ   var "=" shqu( val )     "\n"
}

function juq_if(v){
    if (v !~ "^\".*\"$") return v
    return juq(v)
}

END{
    root = SUBSEP "\"1\""
    if (( e = o[ root , "\"current\"" ] ) != "") {
        p(prefix "_current",  juq(e))
    }

    root = root SUBSEP "\"profile\""

    if (( l = o[ root L ] ) == "") l = 0
    for (i=1; i<=l; ++i) {
        put_nmap( juq(o[ root, jqu(i), jqu("name") ]) , i )
        ll = o[ root, jqu(i) L ]
        for (j=1; j<=ll; ++j) {
            k = o[ root, jqu(i), j ]
            v = o[ root, jqu(i), k ]
            p( prefix "_" i "_" juq(k), juq_if(v) )
        }
    }

    p( prefix "_L", l)
    p( prefix "_nmap", "")

    if (ENVIRON["ENABLE_LOCAL"] != "") {
        CODE_LOCAL = CODE_LOCAL " local " prefix "_unset" "\n"
        printf("{\n%s\n} 2>/dev/null\n\n", substr(CODE_LOCAL, 1, length(CODE_LOCAL)-1) )
    }
    print CODE_EQ

    print prefix "_unset=\"" CODE_UNSET "\""

    print CODE_NAME
}
