
BEGIN{
    HARNESS = ENVIRON[ "harness" ]
    OUTPUT_FORMAT = ENVIRON[ "output_format" ]
    IS_SESSION_FIRST = ENVIRON[ "is_session_first" ]
    USER_SESSION_CWD = ENVIRON[ "user_session_cwd" ]
    SAVE_SESSION_ID_FILE = ENVIRON[ "save_session_id_file" ]
    IS_DEBUG = ENVIRON[ "is_debug" ]

    ____X_CMD_AGENT_ERR_AUTHFAILURE = ENVIRON[ "____X_CMD_AGENT_ERR_AUTHFAILURE" ]
    ____X_CMD_AGENT_ERR_NETWORK_TIMEOUT = ENVIRON[ "____X_CMD_AGENT_ERR_NETWORK_TIMEOUT" ]
    if ( HARNESS == "" ) HARNESS = "UNKNOWN"
    Q2_1 = SUBSEP "\"1\""
    SAVE_SESSION_ID_VAL = ""
}

($0 != ""){ handle_response_stream_json($0); }
# END{ printf( "%s", "\n" ); }

function handle_response_stream_json( s,           o ){
    if ( s ~ "^\\[EXITCODE\\] ([0-9]+) *$" ) {
        stdout_log_debug_if_enabled("EXITCODE", substr(s, 12))
        exit( int(substr(s, 12)) )
    } else if ( OUTPUT_FORMAT == "json" ) {
        print s
        handle_error_text(s, o)
        if (( IS_SESSION_FIRST == 1 ) && ( SAVE_SESSION_ID_VAL == "" )) {
            save_session_id(o)
        }
        fflush()
    } else {
        if (s ~ "^ *\\[DONE\\]$") {
            stdout_log_debug_if_enabled("DONE", "stream finished")
            exit(0)
        }

        handle_error_text(s, o)
        stdout_content(o)
        fflush()

        if (( IS_SESSION_FIRST == 1 ) && ( SAVE_SESSION_ID_VAL == "" )) {
            save_session_id(o)
        }
    }
}

function handle_error_text(s, obj,                  result){
    if (s ~ "^ *\\{"){
        jiparse_after_tokenize(obj, s)
        if ( JITER_LEVEL != 0 ){
            log_error( "agent", "Malformed JSON response from " HARNESS )
            exit(1)
        }

        JITER_LEVEL = JITER_CURLEN = 0

        if (( obj[ Q2_1, "\"type\"" ] == "\"result\"" ) && ( obj[ Q2_1, "\"is_error\"" ] == "true" )) {
            # claude
            result = juq( obj[ Q2_1, "\"result\"" ] )
            log_error( "agent", result )
            # if ( result ~ "^API Error" ){
            exit( 1 )
        } else if ( obj[ Q2_1, "\"type\"" ] == "\"turn.failed\"" ){
            # codex
            log_error( "agent", juq(obj[ Q2_1, "\"error\"", "\"message\"" ] ))
            exit( 1 )
        } else if ( obj[ Q2_1, "\"type\"" ] == "\"error\"" ){
            log_error( "agent", jstr(obj, Q2_1))
            exit( 1 )
        } else if ( obj[ Q2_1, "\"error\"" ] == "{" ){
            log_error( "agent", jstr(obj, Q2_1 SUBSEP "\"error\""))
            exit( 1 )
        }

    } else {
        stdout_log_debug_if_enabled("TEXT", s)
        if ( s ~ "LLM not set" ) {
            log_error( "agent", s )
            exit( ____X_CMD_AGENT_ERR_AUTHFAILURE )
        } else if ( s ~ "Connection error" ) {
            log_error( "agent", s )
            exit( ____X_CMD_AGENT_ERR_NETWORK_TIMEOUT )
        } else if ( s ~ "Not logged in · Please run /login" ) {
            log_error( "agent", s )
            exit( ____X_CMD_AGENT_ERR_AUTHFAILURE )
        }

        log_error( "agent", s )
        exit(1)
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

function stdout_log_debug_if_enabled(label, msg){
    if ( IS_DEBUG != 1 ) return
    log_debug( "agent", "[" label "] " msg )
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

function stdout_content_codex(o,           type, item_type, text, command, output, tool_name, tool_args, status){
    type = o[ Q2_1, "\"type\"" ]

    if ( IS_DEBUG != 1 ) {
        if ( type != "\"item.completed\"" ) return
        item_type = o[ Q2_1, "\"item\"", "\"type\"" ]
        if ( item_type != "\"agent_message\"" ) return
        text = o[ Q2_1, "\"item\"", "\"text\"" ]
        printf( "%s", juq(text) )
        return
    }

    # Debug mode
    if ( type == "\"item.completed\"" ) {
        item_type = o[ Q2_1, "\"item\"", "\"type\"" ]

        if ( item_type == "\"agent_message\"" ) {
            text = o[ Q2_1, "\"item\"", "\"text\"" ]
            printf( "%s", juq(text) )
        } else if ( item_type == "\"reasoning\"" ) {
            text = o[ Q2_1, "\"item\"", "\"text\"" ]
            log_debug( "agent", "[codex:reasoning] " substr(juq(text), 1, 200) )
        } else if ( item_type == "\"command_execution\"" ) {
            command = juq(o[ Q2_1, "\"item\"", "\"command\"" ])
            status = juq(o[ Q2_1, "\"item\"", "\"status\"" ])
            output = o[ Q2_1, "\"item\"", "\"aggregated_output\"" ]
            if ( output != "" ) output = " -> " substr(juq(output), 1, 80)
            log_debug( "agent", "[codex:tool_use] " command output " [" status "]" )
        } else if ( item_type == "\"mcp_tool_call\"" ) {
            tool_name = juq(o[ Q2_1, "\"item\"", "\"tool\"" ])
            tool_args = o[ Q2_1, "\"item\"", "\"arguments\"" ]
            status = juq(o[ Q2_1, "\"item\"", "\"status\"" ])
            if ( tool_args != "" ) tool_args = "(" substr(juq(tool_args), 1, 80) ")"
            log_debug( "agent", "[codex:tool_use] mcp/" tool_name tool_args " [" status "]" )
        } else if ( item_type == "\"collab_tool_call\"" ) {
            tool_name = juq(o[ Q2_1, "\"item\"", "\"tool\"" ])
            log_debug( "agent", "[codex:tool_use] collab/" tool_name )
        } else if ( item_type == "\"file_change\"" ) {
            log_debug( "agent", "[codex:file_change] " juq(o[ Q2_1, "\"item\"", "\"status\"" ]) )
        }
    } else if ( type == "\"turn.completed\"" ) {
        log_debug( "agent", "[codex:result] turn completed" )
    }
}

function stdout_content_gemini(o,           type, role, text, tool_name, status, output){
    type = o[ Q2_1, "\"type\"" ]

    if ( IS_DEBUG != 1 ) {
        if ( type != "\"message\"" ) return
        role = o[ Q2_1, "\"role\"" ]
        if ( role != "\"assistant\"" ) return
        text = o[ Q2_1, "\"content\"" ]
        printf( "%s", juq(text) )
        return
    }

    # Debug mode
    if ( type == "\"message\"" ) {
        role = o[ Q2_1, "\"role\"" ]
        if ( role == "\"assistant\"" ) {
            text = o[ Q2_1, "\"content\"" ]
            printf( "%s", juq(text) )
        }
    } else if ( type == "\"tool_use\"" ) {
        tool_name = juq(o[ Q2_1, "\"tool_name\"" ])
        log_debug( "agent", "[gemini-cli:tool_use] " tool_name )
    } else if ( type == "\"tool_result\"" ) {
        tool_name = juq(o[ Q2_1, "\"tool_id\"" ])
        status = juq(o[ Q2_1, "\"status\"" ])
        output = o[ Q2_1, "\"output\"" ]
        if ( output != "" ) output = " -> " substr(juq(output), 1, 80)
        log_debug( "agent", "[gemini-cli:tool_result] " tool_name " [" status "]" output )
    } else if ( type == "\"result\"" ) {
        status = juq(o[ Q2_1, "\"status\"" ])
        log_debug( "agent", "[gemini-cli:result] " status )
    }
}

function stdout_content_kimi(o,           role, content_type, i, l, text, tool_calls, tool_name, tool_args){
    role = o[ Q2_1, "\"role\"" ]

    if ( IS_DEBUG != 1 ) {
        # Non-debug: content is simple string with --final-message-only
        if ( role != "\"assistant\"" ) return
        text = o[ Q2_1, "\"content\"" ]
        printf( "%s", juq(text) )
        return
    }

    # Debug mode: content is array without --final-message-only
    if ( role == "\"assistant\"" ) {
        l = o[ Q2_1, "\"content\"" L ]
        for (i=1; i<=l; ++i) {
            content_type = o[ Q2_1, "\"content\"", "\""i"\"", "\"type\"" ]
            if ( content_type == "\"text\"" ) {
                text = o[ Q2_1, "\"content\"", "\""i"\"", "\"text\"" ]
                printf( "%s\n", juq(text) )
            } else if ( content_type == "\"thinking\"" ) {
                text = o[ Q2_1, "\"content\"", "\""i"\"", "\"thinking\"" ]
                log_debug( "agent", "[kimi:thinking] " substr(juq(text), 1, 200) )
            }
        }
        # Check tool_calls
        tool_calls = o[ Q2_1, "\"tool_calls\"" L ]
        for (i=1; i<=tool_calls; ++i) {
            tool_name = juq(o[ Q2_1, "\"tool_calls\"", "\""i"\"", "\"function\"", "\"name\"" ])
            tool_args = o[ Q2_1, "\"tool_calls\"", "\""i"\"", "\"function\"", "\"arguments\"" ]
            if ( tool_args != "" ) tool_args = "(" substr(juq(tool_args), 1, 80) ")"
            log_debug( "agent", "[kimi:tool_use] " tool_name tool_args )
        }
    } else if ( role == "\"tool\"" ) {
        text = o[ Q2_1, "\"content\"" ]
        if ( text != "" ) text = " " substr(juq(text), 1, 200)
        log_debug( "agent", "[kimi:tool_result]" text )
    }
}

function stdout_content_claude(o,           type, i, l, text, content_item_type, tool_name, tool_param, thinking_text, result_preview, desc, subtype, stop_reason){
    type = o[ Q2_1, "\"type\"" ]

    if ( IS_DEBUG != 1 ) {
        # Non-debug: only output assistant text
        if ( type != "\"assistant\"" ) return
        l = o[ Q2_1, "\"message\"", "\"content\"" L ]
        for (i=1; i<=l; ++i){
            content_item_type = o[ Q2_1, "\"message\"", "\"content\"", "\""i"\"", "\"type\"" ]
            if ( content_item_type != "\"text\"" ) return
            text = o[ Q2_1, "\"message\"", "\"content\"", "\""i"\"", "\"text\"" ]
            printf( "%s\n", juq(text) )
        }
        return
    }

    # Debug mode: full event logging
    if ( type == "\"assistant\"" ) {
        l = o[ Q2_1, "\"message\"", "\"content\"" L ]
        for (i=1; i<=l; ++i){
            content_item_type = o[ Q2_1, "\"message\"", "\"content\"", "\""i"\"", "\"type\"" ]

            if ( content_item_type == "\"text\"" ) {
                text = o[ Q2_1, "\"message\"", "\"content\"", "\""i"\"", "\"text\"" ]
                printf( "%s\n", juq(text) )
            } else if ( content_item_type == "\"thinking\"" ) {
                thinking_text = o[ Q2_1, "\"message\"", "\"content\"", "\""i"\"", "\"thinking\"" ]
                log_debug( "agent", "[claude:thinking] " substr(juq(thinking_text), 1, 200) )
            } else if ( content_item_type == "\"tool_use\"" ) {
                tool_name = juq(o[ Q2_1, "\"message\"", "\"content\"", "\""i"\"", "\"name\"" ])
                tool_param = ""
                text = o[ Q2_1, "\"message\"", "\"content\"", "\""i"\"", "\"input\"", "\"command\"" ]
                if ( text != "" ) tool_param = juq(text)
                if ( tool_param == "" ) {
                    text = o[ Q2_1, "\"message\"", "\"content\"", "\""i"\"", "\"input\"", "\"description\"" ]
                    if ( text != "" ) tool_param = juq(text)
                }
                if ( tool_param == "" ) {
                    text = o[ Q2_1, "\"message\"", "\"content\"", "\""i"\"", "\"input\"", "\"prompt\"" ]
                    if ( text != "" ) tool_param = substr(juq(text), 1, 80)
                }
                if ( tool_param == "" ) {
                    text = o[ Q2_1, "\"message\"", "\"content\"", "\""i"\"", "\"input\"", "\"subject\"" ]
                    if ( text != "" ) tool_param = juq(text)
                }
                if ( tool_param == "" ) {
                    text = o[ Q2_1, "\"message\"", "\"content\"", "\""i"\"", "\"input\"", "\"taskId\"" ]
                    if ( text != "" ) tool_param = "taskId=" juq(text)
                }
                if ( tool_param == "" ) {
                    text = o[ Q2_1, "\"message\"", "\"content\"", "\""i"\"", "\"input\"", "\"path\"" ]
                    if ( text != "" ) tool_param = juq(text)
                }
                if ( tool_param != "" ) tool_param = "(" tool_param ")"
                log_debug( "agent", "[claude:tool_use] " tool_name tool_param )
            }
        }

    } else if ( type == "\"user\"" ) {
        l = o[ Q2_1, "\"message\"", "\"content\"" L ]
        for (i=1; i<=l; ++i){
            content_item_type = o[ Q2_1, "\"message\"", "\"content\"", "\""i"\"", "\"type\"" ]
            if ( content_item_type == "\"tool_result\"" ) {
                result_preview = o[ Q2_1, "\"message\"", "\"content\"", "\""i"\"", "\"content\"" ]
                if ( result_preview != "" ) {
                    log_debug( "agent", "[claude:tool_result] " substr(juq(result_preview), 1, 200) )
                } else {
                    log_debug( "agent", "[claude:tool_result] (empty)" )
                }
            }
        }

    } else if ( type == "\"system\"" ) {
        subtype = juq(o[ Q2_1, "\"subtype\"" ])
        desc = o[ Q2_1, "\"description\"" ]
        if ( desc == "" ) desc = o[ Q2_1, "\"summary\"" ]
        if ( desc != "" ) {
            log_debug( "agent", "[claude:" subtype "] " juq(desc) )
        } else {
            log_debug( "agent", "[claude:" subtype "]" )
        }

    } else if ( type == "\"result\"" ) {
        stop_reason = o[ Q2_1, "\"stop_reason\"" ]
        log_debug( "agent", "[claude:result] " juq(stop_reason) )
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
    }
}

function stdout_content_opencode(o,           type, part_type, text, tool_name, tool_cmd, tool_status, tool_output, reason){
    type = o[ Q2_1, "\"type\"" ]

    if ( IS_DEBUG != 1 ) {
        if ( type != "\"text\"" ) return
        part_type = o[ Q2_1, "\"part\"", "\"type\"" ]
        if ( part_type != "\"text\"" ) return
        text = o[ Q2_1, "\"part\"", "\"text\"" ]
        printf( "%s\n", juq(text) )
        return
    }

    # Debug mode
    if ( type == "\"text\"" ) {
        part_type = o[ Q2_1, "\"part\"", "\"type\"" ]
        if ( part_type == "\"text\"" ) {
            text = o[ Q2_1, "\"part\"", "\"text\"" ]
            printf( "%s", juq(text) )
        }
    } else if ( type == "\"reasoning\"" ) {
        text = o[ Q2_1, "\"part\"", "\"text\"" ]
        log_debug( "agent", "[opencode:thinking] " substr(juq(text), 1, 200) )
    } else if ( type == "\"tool_use\"" ) {
        tool_name = juq(o[ Q2_1, "\"part\"", "\"tool\"" ])
        tool_cmd = juq(o[ Q2_1, "\"part\"", "\"state\"", "\"input\"", "\"command\"" ])
        log_debug( "agent", "[opencode:tool_exec] " tool_name "(" tool_cmd ")" )
        tool_output = o[ Q2_1, "\"part\"", "\"state\"", "\"output\"" ]
        if ( tool_output != "" ) log_debug( "agent", "[opencode:tool_result] " substr(juq(tool_output), 1, 200) )
    } else if ( type == "\"step_finish\"" ) {
        reason = juq(o[ Q2_1, "\"part\"", "\"reason\"" ])
        log_debug( "agent", "[opencode:result] " reason )
    }
}
