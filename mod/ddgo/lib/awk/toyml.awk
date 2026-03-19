
BEGIN{
    idx = 0
    STATE = 0
    if (HAS_COLOR == 1) {
        DDGO_UI_END          = UI_END
        DDGO_UI_FG_YELLOW    = UI_FG_YELLOW
        DDGO_UI_FG_CYAN      = UI_FG_CYAN
        DDGO_UI_FG_GREEN     = UI_FG_GREEN
        DDGO_UI_FG_BLUE      = UI_FG_BLUE
        DDGO_UI_FG__WHITE    = UI_FG_WHITE
    }
}

function dump2tty(short, long, url, update){
    idx += 1
    printf("%s%s%s", DDGO_UI_FG_CYAN, short, DDGO_UI_END)
    printf("  %s%s%s\n", DDGO_UI_FG_GREEN, long, DDGO_UI_END)
    printf("  url: %s%s%s\n\n", DDGO_UI_FG_YELLOW, url, DDGO_UI_END)

    if (update != ""){
        printf("  update: %s%s%s\n\n", DDGO_UI_FG_BLUE, update, DDGO_UI_END)
    }

    if(idx == TOP) exit(0)
}

function dump2text(short, long, url, update){
    idx += 1
    printf("- idx: %s\n",  idx)
    printf("  short: %s\n", jqu(short))
    printf("  long: %s\n", jqu(long))
    printf("  url: %s\n" , url)

    if (update != ""){
        printf("  update: %s%s%s\n\n", DDGO_UI_FG_BLUE, update, DDGO_UI_END)
    }else printf "\n"

    if(idx == TOP) exit(0)
}


$1~/^1/{ STATE=1; }
STATE!=1{ next }

STATE == 1{
    if(CONTENT == 1){
        if ($0 ~ /^[0-9 ]+[.][ ][ ]/) {

            CONTENT = 0
            handle_content(content, l)
        }else{
            if($0 != "")  content[ ++l ] = str_trimspace( $0 )
            else          CONTENT = 0
        }
    }

    if(($0 ~ /^[0-9 ]+[.][ ][ ]/)&&(CONTENT == 0)){
        $1 = ""
        short = str_trimspace( $0 )
        if(short != ""){
            CONTENT = 1
            l = 0
        }
    }
}

END{ if(TOP == "") handle_content(content, l-1) }
function str_trimspace( s ){  gsub(/^[ \t\n]+/, "", s); return s; }
function str_trimspace2( s ){  gsub(/[ \t\n]+$/, "", s); return s; }

function handle_content(content, l,      i, long, url, arr, len, update){
    l = l -1
    url = content[ l ]
    len = split( url, arr, "[ ]+" )

    url = str_trimspace(arr[1])
    if(arr[2] != "")update = str_trimspace(substr(arr[2], 0, index(arr[2],"T")-1))

    if(url ~ "^[20].*"){
        update = content[ l ]
        update = str_trimspace(substr(arr[2], 0, index(arr[2],"T")-1))
        url = content[ l -1 ]
    }

    if(content[ l ] !~ "^[20].*") for (i=1; i<=l-1; ++i) long = long   str_trimspace2(str_trimspace(content[i]))
    else                          for (i=1; i<=l-2; ++i) long = long   str_trimspace2(str_trimspace(content[i])) 

    if (HAS_COLOR == 1){
        dump2tty(short, long, url, update)
    } else {
        dump2text(short, long, url, update)
    }
    delete content
}