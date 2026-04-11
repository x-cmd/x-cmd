# shellcheck shell=dash disable=SC2016
BEGIN{
    HARNESS = ENVIRON[ "harness" ]
    OUTPUT_FORMAT = ENVIRON[ "output_format" ]
    SAVE_SESSION_ID_FILE = ENVIRON[ "save_session_id_file" ]
    if ( HARNESS == "" ) HARNESS = "UNKNOWN"
    Q2_1 = SUBSEP "\"1\""
    SAVE_SESSION_ID_VAL = ""
}

($0 != ""){ handle_response_stream_json($0); }
# END{ printf( "%s", "\n" ); }

function handle_response_stream_json( s,           o ){
    if ( OUTPUT_FORMAT == "json" ) {
        print s
        fflush()
        if (( SAVE_SESSION_ID_FILE != "" ) && ( SAVE_SESSION_ID_VAL == "" )) {
            jiparse_after_tokenize(o, s)
            save_session_id(o)
        }
    } else {
        if (s ~ "^ *\\[DONE\\]$") exit(0)
        if (s !~ "^ *\\{") return

        jiparse_after_tokenize(o, s)

        if ( JITER_LEVEL != 0 ){
            log_error( "agent", "The response output json format is incorrect")
            exit(1)
        }

        JITER_LEVEL = JITER_CURLEN = 0
        stdout_content(o)

        if (( SAVE_SESSION_ID_FILE != "" ) && ( SAVE_SESSION_ID_VAL == "" )) {
            save_session_id(o)
        }
    }
}

function stdout_content(o){
    if ( HARNESS == "codex" ){
        stdout_content_codex(o)
    } else if ( HARNESS == "gemini-cli" ){
        stdout_content_gemini(o)
    } else if ( HARNESS == "opencode" ){
        stdout_content_opencode(o)
    }
}

function save_session_id(o,           type, session_id){
    if ( HARNESS == "codex" ){
        type = o[ Q2_1, "\"type\"" ]
        if ( type != "\"thread.started\"" ) return
        session_id = juq(o[ Q2_1, "\"thread_id\"" ])
        if ( session_id != "" ) {
            print session_id > SAVE_SESSION_ID_FILE
            SAVE_SESSION_ID_VAL = session_id
        }

    } else if ( HARNESS == "gemini-cli" ){
        type = o[ Q2_1, "\"type\"" ]
        if ( type != "\"init\"" ) return
        session_id = juq(o[ Q2_1, "\"session_id\"" ])
        if ( session_id != "" ) {
            print session_id > SAVE_SESSION_ID_FILE
            SAVE_SESSION_ID_VAL = session_id
        }

    } else if ( HARNESS == "opencode" ){
        type = o[ Q2_1, "\"type\"" ]
        if ( type != "\"step_start\"" ) return

        session_id = juq(o[ Q2_1, "\"sessionID\"" ])
        if ( session_id != "" ) {
            print session_id > SAVE_SESSION_ID_FILE
            SAVE_SESSION_ID_VAL = session_id
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

function stdout_content_gemini(o,           type, role, text){
    type = o[ Q2_1, "\"type\"" ]
    if ( type != "\"message\"" ) return
    role = o[ Q2_1, "\"role\"" ]
    if ( role != "\"assistant\"" ) return

    text = o[ Q2_1, "\"content\"" ]
    printf( "%s", juq(text) )
    fflush()
}

function stdout_content_opencode(o,           type, text){
    type = o[ Q2_1, "\"type\"" ]
    if ( type != "\"text\"" ) return
    type = o[ Q2_1, "\"part\"", "\"type\"" ]
    if ( type != "\"text\"" ) return

    text = o[ Q2_1, "\"part\"", "\"text\"" ]
    printf( "%s", juq(text) )
    fflush()
}
