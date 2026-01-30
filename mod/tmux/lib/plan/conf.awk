
BEGIN{
    if ("" == TMUX_CMD  )     TMUX_CMD = "___x_cmd___tmux_origin "
    if ("" == SHELL_CMD )    SHELL_CMD = "${SHELL:-sh}"

    PANEL_BASE_INDEX = ENVIRON[ "PANEL_BASE_INDEX" ]
    if (PANEL_BASE_INDEX == "") PANEL_BASE_INDEX = 0

}

{   if ($0 != "") jiparse_after_tokenize(obj, $0);  }

END{
    generate_code( obj )
    print CODE
}

function TADD( code ){
    CODE = (CODE == "") ? (TMUX_CMD " " code) : (CODE "\\; " code)
}

function generate_code( obj,        _name, _root, l, i, _panel, _window_root, _kp ){
    _name = jget( obj, "1.name" )
    _root = jget( obj, "1.root" )

    TMUX_CMD " has-session -t " _name " 2>/dev/null; echo $?" | getline l
    if (l == 0) {
        TADD( "attach -t " _name )
        return
    }

    TADD("new -s " _name )

    _kp = SUBSEP jqu("1") SUBSEP jqu( "windows" )
    for (i=1; i<=obj[ _kp L ]; ++i) prepare_window( i )

    TADD("kill-window -t 0")
}

function shell_quote_cmd( exec ){
    gsub("\"", "\\\"", exec)
    exec = "export ___X_CMD_TMUX_EXEC=\"" exec "\"; "

    # cmd = exec ". \"\\$___X_CMD_ROOT_MOD/tmux/lib/xsh\""
    cmd = exec SHELL_CMD " \"\\$___X_CMD_ROOT_MOD/tmux/lib/plan/xsh\""

    gsub("\"", "\\\"", cmd)
    cmd = SHELL_CMD " -ic "  "\"" cmd "\""

    return cmd
}

function find_exec( kp, _code ){
    ___kp = kp
    _root = ""
    while (obj[ ___kp, jqu("panes") ] == "[") {
        if ("" != obj[___kp, jqu("root")])      _root = obj[___kp, jqu("root")]
        ___kp = ___kp SUBSEP jqu("panes") SUBSEP jqu(1)
    }

    _exec = obj[ ___kp ]
    if (_exec == "{" ) {
        if ("" != obj[ ___kp, jqu("root") ])    _root = obj[___kp, jqu("root")]
        _exec = obj[ ___kp, jqu("x") ]
        if (_exec != "") {
            _exec = shell_quote_cmd( juq( _exec ) )
        } else {
            _exec = shell_quote_cmd( juq( obj[ ___kp, jqu("exec") ] ) )
        }
    } else if (_exec == "[") {
        # Using Recursive
        return find_exec( ___kp SUBSEP 0 )
    } else {
        _exec = shell_quote_cmd( juq( _exec ) )
    }

    if ( _root != "")       _code = _code " -c " _root " "
    if ( _exec != "")       _code = _code " " _exec " "
    return _code
}

function cal_layout( value, last_layout ){
    if (value == "") {
        return (last_layout == "-h") ? "-v" : "-h"
    }
    return (value == "\"vertical\"") ? "-v" : "-h"
}

function prepare_window( i,                         _name, _root, _exec, _kp ){
    _kp = SUBSEP jqu("1") SUBSEP jqu( "windows" ) SUBSEP jqu(i)

    _name = obj[ _kp, jqu("name") ]
    if ( _name != "")       _name = " -n " _name
    TADD( "new-window " _name " " find_exec( _kp ) )

    biggest_panel_id = prepare_panel( _kp SUBSEP jqu("panes"), PANEL_BASE_INDEX, cal_layout(obj[ _kp, jqu("layout") ], "-v") )
}

function prepare_panel( kp, pane_id, layout,        _code, _pane , l, i, _exec, _root, _start_pane_id, PANE_EXEC_LOCAL ){
    l = obj[ kp L ]

    if (pane_id != "")      _pane = " -t:." pane_id " "

    for (i=1; i<=l; ++i) {
        _value = obj[ kp, jqu(i), jqu("size") ]
        if (_value == "") {
            _size[i] = ""
            continue
        }
        if (_value ~ /^".+"$/)  _value = substr(_value, 2, length(_value)-2)
        _size[i] = int(_value)
    }

    _sum = 0
    _null = 0
    for (i=1; i<=l; ++i) {
        if (_size[i] == "")  _null ++
        else                _sum += _size[i]
    }

    _rest = 100 - _sum
    for (i=2; i<=l; ++i) {
        if (_size[i] == "") _size[i] = _rest / _null
    }

    for (i=l-1; i>=2; --i) _size[i] = _size[i] + _size[i+1]

    for (i=2; i<=l; ++i) TADD( sprintf("split-window %s %s -l %d%% %s", _pane, layout , _size[i], find_exec( kp SUBSEP jqu(i) ) ) )

    for (i=1; i<=l; ++i) {
        if (i>1) pane_id = pane_id + 1
        if (obj[ kp, jqu(i), jqu("panes") ] == "[") {
            pane_id = prepare_panel( kp SUBSEP jqu(i) SUBSEP jqu("panes"), pane_id, cal_layout(obj[ _kp, jqu(i), jqu("layout") ], layout) )
        }
    }

    return pane_id
}
