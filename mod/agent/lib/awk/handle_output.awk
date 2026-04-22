# shellcheck shell=dash disable=SC2016
BEGIN{
    HARNESS = ENVIRON[ "harness" ]
    OUTPUT_FORMAT = ENVIRON[ "output_format" ]
    IS_SESSION_FIRST = ENVIRON[ "is_session_first" ]
    USER_SESSION_CWD = ENVIRON[ "user_session_cwd" ]
    SAVE_SESSION_ID_FILE = ENVIRON[ "save_session_id_file" ]

    ____X_CMD_AGENT_ERR_AUTHFAILURE = ENVIRON[ "____X_CMD_AGENT_ERR_AUTHFAILURE" ]
    ____X_CMD_AGENT_ERR_NETWORK_TIMEOUT = ENVIRON[ "____X_CMD_AGENT_ERR_NETWORK_TIMEOUT" ]
    if ( HARNESS == "" ) HARNESS = "UNKNOWN"
    Q2_1 = SUBSEP "\"1\""
    SAVE_SESSION_ID_VAL = ""
}

($0 != ""){ handle_response_stream_json($0); }
# END{ printf( "%s", "\n" ); }

function handle_response_stream_json( s,           o ){
    if ( OUTPUT_FORMAT == "json" ) {
        print s
        handle_error_text(s)
        fflush()
        if (( IS_SESSION_FIRST == 1 ) && ( SAVE_SESSION_ID_VAL == "" )) {
            jiparse_after_tokenize(o, s)
            save_session_id(o)
        }
    } else {
        if (s ~ "^ *\\[DONE\\]$") exit(0)

        handle_error_text(s)
        if (s !~ "^ *\\{") return

        jiparse_after_tokenize(o, s)

        if ( JITER_LEVEL != 0 ){
            log_error( "agent", "The response output json format is incorrect")
            exit(1)
        }

        JITER_LEVEL = JITER_CURLEN = 0
        stdout_content(o)

        if (( IS_SESSION_FIRST == 1 ) && ( SAVE_SESSION_ID_VAL == "" )) {
            save_session_id(o)
        }
    }
}

function handle_error_text(s,           obj, result){
    if ( HARNESS == "kimi-cli" ){
        if ( s ~ "LLM not set" ) {
            log_error( "agent", s )
            exit( ____X_CMD_AGENT_ERR_AUTHFAILURE )
        }
        else if ( s ~ "Connection error" ) {
            log_error( "agent", s )
            exit( ____X_CMD_AGENT_ERR_NETWORK_TIMEOUT )
        }
    } else if ( HARNESS == "claude" ){
        if ( s ~ "Not logged in · Please run /login" ) {
            log_error( "agent", s )
            exit( ____X_CMD_AGENT_ERR_AUTHFAILURE )
        }

        if (s !~ "^ *\\{") return
        jiparse_after_tokenize(obj, s)
        JITER_LEVEL = JITER_CURLEN = 0
        if (( obj[ Q2_1, "\"type\"" ] == "\"result\"" ) && ( obj[ Q2_1, "\"is_error\"" ] == "true" )) {
            result = juq( obj[ Q2_1, "\"result\"" ] )
            if ( result ~ "^API Error" ){
                exit( 1 )
            }
        }
    } else if ( HARNESS == "codex" ){
        if (s !~ "^ *\\{") return
        jiparse_after_tokenize(obj, s)
        JITER_LEVEL = JITER_CURLEN = 0
        if ( obj[ Q2_1, "\"type\"" ] == "\"turn.failed\"" ){
            log_error( "agent", juq(obj[ Q2_1, "\"error\"", "\"message\"" ] ))
            exit( 1 )
        }
    }
}

function stdout_content(o){
    if ( HARNESS == "claude" ){
        stdout_content_claude(o)
    } else if ( HARNESS == "cursor" ){
        stdout_content_cursor(o)
    } else if ( HARNESS == "codex" ){
        stdout_content_codex(o)
    } else if ( HARNESS == "gemini-cli" ){
        stdout_content_gemini(o)
    } else if ( HARNESS == "opencode" ){
        stdout_content_opencode(o)
    } else if ( HARNESS == "kimi-cli" ){
        stdout_content_kimi(o)
    }
}

function save_session_id(o,           type, session_id){
    if ( HARNESS == "codex" ){
        type = o[ Q2_1, "\"type\"" ]
        if ( type != "\"thread.started\"" ) return
        session_id = juq(o[ Q2_1, "\"thread_id\"" ])
        if ( session_id != "" ) {
            printf("%s\n%s\n", session_id, USER_SESSION_CWD) > SAVE_SESSION_ID_FILE
            SAVE_SESSION_ID_VAL = session_id
        }

    } else if ( HARNESS == "gemini-cli" ){
        type = o[ Q2_1, "\"type\"" ]
        if ( type != "\"init\"" ) return
        session_id = juq(o[ Q2_1, "\"session_id\"" ])
        if ( session_id != "" ) {
            printf("%s\n%s\n", session_id, USER_SESSION_CWD) > SAVE_SESSION_ID_FILE
            SAVE_SESSION_ID_VAL = session_id
        }

    } else if ( HARNESS == "opencode" ){
        type = o[ Q2_1, "\"type\"" ]
        if ( type != "\"step_start\"" ) return

        session_id = juq(o[ Q2_1, "\"sessionID\"" ])
        if ( session_id != "" ) {
            printf("%s\n%s\n", session_id, USER_SESSION_CWD) > SAVE_SESSION_ID_FILE
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

function stdout_content_kimi(o,           role, text){
    role = o[ Q2_1, "\"role\"" ]
    if ( role != "\"assistant\"" ) return

    text = o[ Q2_1, "\"content\"" ]
    printf( "%s", juq(text) )
    fflush()
}

function stdout_content_claude(o,           type, i, l, text, content_type){
    type = o[ Q2_1, "\"type\"" ]
    if ( type != "\"assistant\"" ) return

    l = content_type = o[ Q2_1, "\"message\"", "\"content\"" L ]
    for (i=1; i<=l; ++i){
        content_type = o[ Q2_1, "\"message\"", "\"content\"", "\""i"\"", "\"type\"" ]
        if ( content_type != "\"text\"" ) return

        text = o[ Q2_1, "\"message\"", "\"content\"", "\""i"\"", "\"text\"" ]
        printf( "%s\n", juq(text) )
        fflush()
    }
}

# TODO: Verify cursor stream-json format and adjust accordingly
function stdout_content_cursor(o,           type, i, l, text, content_type){
    type = o[ Q2_1, "\"type\"" ]
    if ( type != "\"assistant\"" ) return

    l = content_type = o[ Q2_1, "\"message\"", "\"content\"" L ]
    for (i=1; i<=l; ++i){
        content_type = o[ Q2_1, "\"message\"", "\"content\"", "\""i"\"", "\"type\"" ]
        if ( content_type != "\"text\"" ) return

        text = o[ Q2_1, "\"message\"", "\"content\"", "\""i"\"", "\"text\"" ]
        printf( "%s\n", juq(text) )
        fflush()
    }
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
