# Section: NR==1    DATA SOURCE parsing
BEGIN {
    ATT_DESC    = "\007"
    ATT_VAR     = "\004"

    ATT_DEFAULT = "\005"
    ATT_OP      = "\006"
    # ATT_OP_L    = "\007"

    ATT_ANS     = "\010"

    # FS="\001"/
}

NR==1{
    if (RS == "\n") {
        gsub("\001", "\n", $0)
    }
    # TODO: in some case. There is a bug
    argl = split($0, args, "\002")

    rulel = 0
    for (i=1; i<=argl; ++i) {
        rulel = rulel + 1
        desc = str_trim(args[i])
        rule[ rulel ATT_DESC ]              = desc
        l = wcswidth(desc)
        if (question_width < l) question_width = l
        rule[ rulel ATT_VAR ]               = args[i+1]
        rule[ rulel ATT_DEFAULT ]           = args[i+2]
        if (args[i+3] == "--") {
            i=i+3
            rule[ rulel ATT_OP ] = ""
            continue
        }

        rule[ rulel ATT_OP ] = args[i+3]
        # printf(i+1 ": %s\n", args[i+1]) >"/dev/stderr"
        # printf(i+2 ": %s\n", args[i+2]) >"/dev/stderr"
        # printf("op: > " i+3 ": %s\n", args[i+3]) >"/dev/stderr"

        i = i + 4
        for (j=i; j<=argl; ++j) {
            if (args[j] == "--") break
            rule[ rulel L (j-i+1) ] = args[j]
        }
        rule[ rulel L ] = j-i
        i=j
    }

    for (i=1; i<=rulel; ++i) {
        question            = rule[ i ATT_DESC ]
        if ( rule[ i ATT_OP ] != "=" ) {
            ctrl_lineedit_init( rule, i ATT_ANS  )
            ctrl_lineedit_put(  rule, rule[ i ATT_DEFAULT ], i ATT_ANS )
        } else {
            tmp = rule[ i ATT_DEFAULT ]
            ctrl_rstate_init( rule, 1, rule[ i L ], i ATT_ANS )
            ctrl_lineedit_init( rule, i ATT_ANS  )

            if ( tmp == "" ) continue
            for (j=1; j<=rule[ i L ]; ++j){
                if ( tmp == rule[ i L j ]) {
                    ctrl_rstate_set( rule, j, i ATT_ANS )
                    break
                }
            }
        }
    }

    ctrl_rstate_init( CURRENT, 1, rulel+1 )
}
# EndSection

# Section: ctrl
BEGIN {
    if (exit_strategy == "")  exit_strategy = "execute"                  # "execute|save|exit"
    exit_strategy_arrl = split(exit_strategy, exit_strategy_arr, "|")
    ctrl_exit_strategy =  ctrl_rstate_init( EXIT, 1, exit_strategy_arrl )
}

function ctrl( char_type, char_value,                   _ctrl_current, _current_id, _current_val ) {
    if (char_value == "UP")             return ctrl_rstate_dec( CURRENT )
    if (char_value == "DN")             return ctrl_rstate_inc( CURRENT )

    _ctrl_current = ctrl_rstate_get( CURRENT )
    if (_ctrl_current == rulel + 1) {
        if (char_value == "ENTER")      exit(0)
        if (char_value == "LEFT")       return ctrl_rstate_dec( EXIT )
        if (char_value == "RIGHT")      return ctrl_rstate_inc( EXIT )
    } else {
        if (char_value == "ENTER")      return ctrl_rstate_inc( CURRENT )       # _ctrl_current != rule + 1
        if (rule[ _ctrl_current ATT_OP ] == "="){
            _current_id = ctrl_rstate_get( rule, _ctrl_current ATT_ANS )
            _current_val = rule[ _ctrl_current L _current_id ]
            if ( is_regex(_current_val) )   ctrl_lineedit_handle(  rule, _ctrl_current ATT_ANS, char_type, char_value )
            if (char_value == "LEFT")       return ctrl_rstate_dec( rule, _ctrl_current ATT_ANS )
            if (char_value == "RIGHT")      return ctrl_rstate_inc( rule, _ctrl_current ATT_ANS )
        } else{
            ctrl_lineedit_handle(  rule, _ctrl_current ATT_ANS, char_type, char_value )
        }
    }
}

# EndSection

# Section: view
function view(            errormsg, _ctrl_current, _component_help, _component_body, _component_exit  ){
    _ctrl_current = ctrl_rstate_get( CURRENT )

    errormsg = display_ui_errormsg( rulel, max_row_size-5, max_col_size)
    if (errormsg != "") {
        ctrl_rstate_set(CURRENT, rulel+1)
        ctrl_rstate_set(EXIT, 0)
        return send_update( errormsg )
    }

    _component_line = ui_str_rep( "─", max_col_size )
    _component_body = view_body( _ctrl_current )
    _component_exit = view_exit( _ctrl_current )
    _component_help = view_help( _ctrl_current )

    send_update( _component_line "\n" _component_body "\n" _component_exit _component_help  )
}

function view_help( _ctrl_current,              data ){
    if ( FORM_HELP_STATE == "0" ) return
    data = "Press <Arrow-Up> and <Arrow-Down> to alternate question" "\n"
    if (rule[ _ctrl_current ATT_OP ] == "=") {
        data = data "Press <Arrow-Left> and <Arrow-Right> to alternative choice, or input digit."
    }
    return th( TH_FORM_Q_HELP, data )
}

function view_body_cal_beginning_col( _current_col, _current_row,        _col_size, j, _len){
    _col_size = max_col_size - question_width - 6
    for (j=_current_col; j>=1; --j) {
        _len = length(rule[ _current_row L j ]) + 1
        if (_col_size < _len) return j+1
        _col_size -= _len
    }
    return 1
}

function view_body( _ctrl_current,              data, _question, _line, _answer, _answer_id, _answer_style, _is_focused, _is_selected,  i, j, op, _col_start, STYLE_ANSWER_SELECTED, STYLE_ANSWER_UNSELECTED ){
    for (i=1; i<=rulel; ++i) {
        _question       =  sprintf( "%-" question_width + 2 "s",   rule[ i ATT_DESC ] )
        _is_focused     =  _ctrl_current == i

        if ( _is_focused ) {
            STYLE_ANSWER_SELECTED       = TH_FORM_A_FOCUSED_SELECTED
            STYLE_ANSWER_UNSELECTED     = TH_FORM_A_FOCUSED_NOTSELECTED
            _line                       = th(TH_FORM_Q_ARROW, "> ") th( TH_FORM_Q_FOCUSED, _question  ": " )
        } else {
            STYLE_ANSWER_SELECTED       = TH_FORM_A_UNFOCUSED_SELECTED
            STYLE_ANSWER_UNSELECTED     = TH_FORM_A_UNFOCUSED_NOTSELECTED
            _line                       = th( TH_FORM_Q_UNFOCUSED,  "  " _question  ": " )
        }

        op = rule[ i ATT_OP ]
        if (op != "=") {
            _answer       = ctrl_lineedit_get( rule, i ATT_ANS )
            _answer_style = TH_FORM_Q_TRUE
            if (op ~ "=~") _answer_style = (judgment_of_regexp( rule, i, _answer )) ? TH_FORM_Q_TRUE : TH_FORM_Q_FALSE
            _answer       = (op !~ /\*/) ? _answer : ui_str_rep( "*", length(_answer) )
            _answer       = ( !_is_focused ) ? _answer : _answer th(TH_CURSOR, " ")
            _line         = _line th( _answer_style, _answer)
        } else {
            _answer_id  = ctrl_rstate_get( rule, i ATT_ANS )
            _col_start  = view_body_cal_beginning_col( _answer_id, i )
            for (j=_col_start; j<=rule[ i L ]; ++j) {
                _is_selected    = _answer_id == j
                _answer = rule[ i L j ]

                if (is_regex(_answer) ) {
                    _answer = ctrl_lineedit_get( rule, i ATT_ANS )
                    _answer_style = (judgment_of_regexp_or_candidate( rule, i, _answer )) ? TH_NOT : TH_FORM_Q_FALSE
                    _answer = th( _answer_style, _answer)
                    _answer = ( !_is_focused ) ? _answer : _answer th(TH_CURSOR, " ")
                }
                _answer = th( _is_selected ? STYLE_ANSWER_SELECTED: STYLE_ANSWER_UNSELECTED, _answer )
                _line           = _line _answer " "
            }
        }
        data = data _line "\n"
    }
    return data
}

# I don't know ... It has not been well-designed yet.
function view_exit( _ctrl_current,              data, _is_focused, _is_selected, i, STYLE_EXIT, STYLE_EXIT_NOT ){
    if (exit_strategy_arrl == 1) return
    _is_focused = _ctrl_current == rulel+1
    if ( _is_focused ) {
        STYLE_EXIT      = TH_FORM_A_FOCUSED_SELECTED
        STYLE_EXIT_NOT  = TH_FORM_A_FOCUSED_NOTSELECTED
    } else {
        STYLE_EXIT      = TH_FORM_A_UNFOCUSED_SELECTED
        STYLE_EXIT_NOT  = TH_FORM_A_UNFOCUSED_NOTSELECTED
    }
    _ctrl_exit_strategy = ctrl_rstate_get( EXIT )
    for (i=1; i<=exit_strategy_arrl; ++i) {
        _is_selected    = _ctrl_exit_strategy == i
        data            = data "   " th( _is_selected ? STYLE_EXIT : STYLE_EXIT_NOT,    exit_strategy_arr[i] )
    }
    return data "\n"
}

# EndSection

# Section: NR>1     command stream and end
NR>1{
    if ( try_update_width_height( $0 ) == true ) view()
    if ($0 ~ /^R:/)  next
    cmd=$0
    gsub(/^C:/, "", cmd)
    idx = index(cmd, ":")
    ctrl(substr(cmd, 1, idx-1), substr(cmd, idx+1))
    if ( ( exit_strategy_arrl == 1 ) && ( ctrl_rstate_get( CURRENT ) == rulel + 1 ) ) exit(0)
    view()
}

END {
    send_env("___X_CMD_UI_FORM_EXIT", exit_strategy_arr[ ctrl_rstate_get( EXIT ) ])
    if (( exit_strategy_arr[ ctrl_rstate_get( EXIT ) ] != "exit" ) && (ctrl_rstate_get( EXIT ) != 0)) {
        for (i=1; i<=rulel; ++i) {
            var =       rule[ i ATT_VAR ]
            if (rule[ i ATT_OP ] == "=")    {
                _answer = rule[ i L ctrl_rstate_get( rule, i ATT_ANS ) ]
                if ( is_regex(_answer) ) _answer = ctrl_lineedit_get( rule, i ATT_ANS )
            } else {
                _answer = ctrl_lineedit_get( rule, i ATT_ANS )
            }
            send_env( var, _answer )
        }
    }
}
# EndSection
