# shellcheck shell=dash disable=SC2016
BEGIN{
    HARNESS = ENVIRON[ "harness" ]
    if ( HARNESS == "" ) HARNESS = "UNKNOWN"
    Q2_1 = SUBSEP "\"1\""
}

($0 != ""){ handle_response_stream_json($0); }

function handle_response_stream_json( s,           o ){
    if (s ~ "^ *\\[DONE\\]$") exit(0)
    if (s !~ "^ *\\{") return

    jiparse_after_tokenize(o, s)

    if ( JITER_LEVEL != 0 ){
        log_error( "agent", "The response output json format is incorrect")
        exit(1)
    }

    JITER_LEVEL = JITER_CURLEN = 0
    stdout_content(o)
}

function stdout_content(o){
    if ( HARNESS == "KIMI" ){
        stdout_content_kimi(o)
    } else if ( HARNESS == "CODEX" ){
        stdout_content_codex(o)
    } else if ( HARNESS == "CLAUDE" ){
        stdout_content_claude(o)
    } else if ( HARNESS == "GEMINI" ){
        stdout_content_gemini(o)
    } else if ( HARNESS == "OPENCODE" ){
        stdout_content_opencode(o)
    }
}

function stdout_content_kimi( o,           role, content_l, i, type, text ){
    role = o[ Q2_1, "\"role\"" ]
    if ( role != "\"assistant\"" ) return

    content_l = o[ Q2_1, "\"content\"" L ]
    for (i=1; i<=content_l; ++i){
        type = o[ Q2_1, "\"content\"", "\""i"\"", "\"type\"" ]
        if ( type == "\"text\"" ){
            text = o[ Q2_1, "\"content\"", "\""i"\"", "\"text\"" ]
            printf( "%s", juq(text) )
            fflush()
        }
    }
}

function stdout_content_codex(o,           type, text){
    type = o[ Q2_1, "\"type\"" ]
    if ( type != "\"item.completed\"" ) return

    type = o[ Q2_1, "\"item\"", "\"type\"" ]
    if ( type != "\"agent_message\"" ) return

    text = o[ Q2_1, "\"item\"", "\"text\"" ]
    printf( "%s", juq(text) )
    fflush()
}

function stdout_content_claude(o,           type, text, content_l, i){
    type = o[ Q2_1, "\"type\"" ]
    if ( type != "\"assistant\"" ) return

    content_l = o[ Q2_1, "\"message\"", "\"content\"" L ]
    for (i=1; i<=content_l; ++i){
        type = o[ Q2_1, "\"message\"", "\"content\"", "\""i"\"", "\"type\"" ]
        if ( type == "\"text\"" ){
            text = o[ Q2_1, "\"message\"", "\"content\"", "\""i"\"", "\"text\"" ]
            printf( "%s", juq(text) )
            fflush()
        }
    }
}

function stdout_content_gemini(o,           type, text){
    type = o[ Q2_1, "\"type\"" ]
    if ( type != "\"output\"" ) return

    text = o[ Q2_1, "\"content\"" ]
    printf( "%s", juq(text) )
    fflush()
}

function stdout_content_opencode(o,           type, text){
    type = o[ Q2_1, "\"type\"" ]
    if ( type != "\"message\"" ) return

    text = o[ Q2_1, "\"content\"" ]
    printf( "%s", juq(text) )
    fflush()
}
