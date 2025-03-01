

BEGIN{
    FMT =  "%-12s %4d %8s %-10s %10d %3d%3d%6s"

    FACL_FMT = "%3s\t%s\t%s\t%s"

    SKIP = ENVIRON["SKIP"]
    if (SKIP == "")  SKIP = 1
}


#  file mode, number of links, owner name, group name, number of bytes in the file, abbreviated month, day-of-month file
function visualize( d, num ){
    $0 = d
    _MODE   = $1
    _LINK   = $2
    _USER   = $3
    _GRP    = $4
    _BYTE   = $5
    _MONTH  = $6
    _DAY    = $7
    _TIME   = $8

    $1 = $2 = $3 = $4 = $5 = $6 = $7 = $8 = ""
    _FP     = $0
    gsub("(^[ \t]+)|([ \t]+$)", "", _FP)

    if ( num == 0 ) {
        printf( "  \033[2m"         FMT         "\033[0m"       ,   _MODE, _LINK, _USER, _GRP, _BYTE, _MONTH, _DAY, _TIME )
        printf( "  \033[2m"         "%s"        "\033[0m" "\n"  ,   _FP )
    } else {
        printf( "  \033[2m"         FMT         "\033[0m"       ,   _MODE, _LINK, _USER, _GRP, _BYTE, _MONTH, _DAY, _TIME )
        printf( "  \033[4;1;34m"    "%s"        "\033[0m" "\n"   ,   _FP )
    }

    # printf( FMT "\n", _MODE, _LINK, _USER, _GRP, _BYTE, _MONTH, _DAY, _TIME, _FP )
}

function visualize_facl( d ){
    $0 = d
    # printf( FACL_FMT "\n", $1, $2, $3, $4 )
    # print d

    _NO     = $1;  gsub(/:$/, "", _NO )

    _SCOPE  = $2
    _VERB   = $3
    _OP     = $4

    _NO = "\033[34;1m" _NO  "\033[0;2m" ":" "\033[0m"

    if ( _VERB == "deny" )  { _VERB = "\033[31m"    _VERB "\033[0m";  }
    else                    { _VERB = "\033[32;1m"  _VERB "\033[0m";  }

    _OP = "\033[34m" _OP  "\033[0m"


    printf("      %s   %s   %s   %s\n", _NO, _SCOPE, _VERB, _OP )
}

function vis( e,      i ){
    if ( e == "" ) return
    if ((SKIP == 1) && (RULE_NO == 0)) {
        skip_num ++
        return
    }

    visualize( e, RULE_NO )
    for (i=1; i<=RULE_NO; ++i)  visualize_facl( RULE[ i ])
}

function handle(){
    getline
    while (1) {
        SAVE = $0

        vis( ITEM )

        ITEM = SAVE
        RULE_NO = 0

        if (! getline) return

        while ($0 ~ /^[ ][^ ]+/) {
            RULE[ ++ RULE_NO ] = $0
            if (! getline) return
        }
    }
}

BEGIN{
    printf("\n")
    handle()
    vis( ITEM )

    if ( ( SKIP == 1) && (skip_num >0) ) {
        printf("\n\n\033[2;3m")
        printf( "   >>> Having hiden %5d files which have no acl rule.\n", skip_num )
        printf( "   >>> You can use -a or --all to show all files.\n" )
        printf("\n\033[0m")
    }
}


