
# Section: view
BEGIN {
    ctrl_help_item_put("ARROW UP/DOWN/LEFT/ROW", "to move focus")
    ctrl_help_item_put("ENTER", "for enter")
}

function view_calcuate_geoinfo(){
    if ( ctrl_help_toggle_state() == true ) {
        view_body_row_num = max_row_size - 10
    } else {
        view_body_row_num = max_row_size - 9
    }
}


function view(      _component_help, _component_tag, _component_select, _component_preview){
    view_calcuate_geoinfo()
    _component_help         = view_help()
    _component_tag          = view_tag()
    _component_select       = view_select()
    _component_preview      = view_preview()

    send_update( _component_help "\n" _component_tag "\n" _component_select "\n" _component_preview  )
}

function view_help(){
    return sprintf("%s", th_help_text( ctrl_help_get() ) )
}

function view_tag(         i, _tag, _tag_len, _data, _max_tag_len, _head_line, _foot_line, _head_line_item, _foot_line_item, _SELECTED_ITEM_STYLE ){
    for (i=1; i<=THEME_TAG_L; i++){
        _tag = THEME_TAG[ i ]
        _tag_len = THEME_TAG[ i L ] + 4
        _max_tag_len = _max_tag_len + _tag_len
        _tag = str_pad_right( _tag, _tag_len )
        _head_line_item = ui_str_rep(" ", _tag_len)
        _foot_line_item = ui_str_rep("─", _tag_len)

        if (ctrl_sw_get( IS_FOCUS_TAG ) == true) _SELECTED_ITEM_STYLE = TH_THEME_PREVIEW_FOCUSE UI_TEXT_REV
        if ( CUR_TAG_IDX == i ) {
            _head_line_item = "┌" ui_str_rep("─", _tag_len)       "┐"
            _tag            = "│" th(_SELECTED_ITEM_STYLE , _tag) "│"
            _foot_line_item = "┘" ui_str_rep(" ", _tag_len)       "└"
        }
        _head_line = _head_line _head_line_item
        _foot_line = _foot_line _foot_line_item
        _data      = _data  _tag
    }
    _foot_line = _foot_line ui_str_rep("─", max_col_size - _max_tag_len - 2)
    return _head_line "\n" _data "\n" _foot_line
}

# Using grid select
function view_select(        _data, _SELECTED_ITEM_STYLE, page_index, page_begin, i, j, _iter_item_idx, _data_item_text , _item_text ){
    if (model_len == 0){
        _data = "We couldn’t find any data ..."
        _data = str_pad_left(_data, int(max_col_size/2), int(length(_data)/2))
        return th(TH_DATA_UNFIND, _data)
    }
    view_page_item_num  = view_select_col_num * 3
    view_page_num       = int( ( model_len - 1 ) / view_page_item_num ) + 1
    page_index          = int( (CUR_THEME_IDX - 1) / view_page_item_num ) + 1
    page_begin          = int( (page_index - 1) * view_page_item_num)
    view_select_row_num   = int( ( model_len - 1 ) / view_select_col_num ) + 1

    if ( view_select_row_num > 3 ) view_select_row_num = 3
    for (i=0; i<view_select_row_num; i++) {
        for (j=1; j<=view_select_col_num; j++) {
            _iter_item_idx = page_begin + j + ( i * view_select_col_num )
            if (_iter_item_idx > model_len) break
            _data_item_text = THEME_TAG_ITEM[ CUR_TAG _iter_item_idx ]
            _item_text = str_pad_right( _data_item_text, max_theme_len )
            if (ctrl_sw_get( IS_FOCUS_TAG ) == false) _SELECTED_ITEM_STYLE = TH_THEME_PREVIEW_FOCUSE
            if (CUR_THEME_IDX == _iter_item_idx) _item_text = th( _SELECTED_ITEM_STYLE TH_THEME_PREVIEW_SELECT, _item_text)
            _data = _data "    " _item_text
        }
        _data = _data "\n"
    }
    _data = _data ui_str_rep("─", max_col_size)
    return _data
}

function view_preview(             cur_theme, _linel, _line, _data, i){
    if (model_len == 0) return
    cur_theme = THEME_TAG_ITEM[ CUR_TAG CUR_THEME_IDX ]
    _linel = split(PREVIEW[cur_theme], _line, "\n")
    if (_linel > view_body_row_num) _linel = view_body_row_num
    for (i=1; i<=_linel; i++) {
        _data = ( _data != "" ) ? _data "\n" _line[ i ] : _line[ i ]
    }
    return _data
}

# EndSection

# Section: ctrl
function ctrl(char_type, char_value,        _selected, _selected_keypath ){
    exit_if_detected( char_value, ",q," )


    if (char_value == "h")                                return ctrl_help_toggle()
    if (ctrl_sw_get( IS_FOCUS_TAG ) == true) {
        if (char_value == "LEFT")                         return ctrl_rstate_dec( SELECTED_THEME_TAG_IDX )
        if (char_value == "RIGHT")                        return ctrl_rstate_inc( SELECTED_THEME_TAG_IDX )
        if ( (char_value == "DN") && ( model_len > 0 ) )  return ctrl_sw_toggle( IS_FOCUS_TAG )
    } else {
        if (char_value == "LEFT")                         return ctrl_rstate_dec( SELECTED_THEME_IDX )
        if (char_value == "RIGHT")                        return ctrl_rstate_inc( SELECTED_THEME_IDX )
        if (char_value == "DN" )                          return ctrl_rstate_add( SELECTED_THEME_IDX, + view_select_col_num )
        if (char_value == "UP") {
            if (CUR_THEME_IDX <= view_select_col_num) return ctrl_sw_toggle( IS_FOCUS_TAG )
            return ctrl_state_add( SELECTED_THEME_IDX, - view_select_col_num )
        }
        if (char_value == "ENTER" )                       return exit_with_elegant( char_value )
    }
}

# EndSection

# Section: model
function model_generate(){
    CUR_TAG_IDX = ctrl_rstate_get(SELECTED_THEME_TAG_IDX)
    CUR_TAG     = THEME_TAG[ CUR_TAG_IDX ]
    model_len   = THEME_TAG_ITEM[ CUR_TAG L ]
    ctrl_rstate_init( SELECTED_THEME_IDX, 1, model_len )
    view_select_col_num = int(max_col_size / (max_theme_len + 4))
}
# EndSection

# Section: cmd
BEGIN{
    THEME_ARR_L = 0
    PREVIEW_ARR_L = 0
    THEME_TAR_PATH = "~/.x-cmd/.tmp/theme/theme.tgz"
}


function get_theme_arr(         _cmd, _theme, _line){
    _cmd = "tar -f " THEME_TAR_PATH " -t style/ 2>/dev/null"
    while ( _cmd | getline _line ) {
        _theme = substr(_line, 7)
        if ( _theme == "" ) continue
        THEME_ARR[ ++THEME_ARR_L ] = _theme
    }
}

function get_theme_tag(         _cmd, i, _tag, _line, _theme){
    _cmd = "tar -f " THEME_TAR_PATH " -O -x index.yml 2>/dev/null"
    # _cmd = "cat ../xcmd/theme/ui.yml 2>/dev/null"
    THEME_TAG_L = 0
    while ( _cmd | getline _line) {
        if ( _line == "" ) continue
        if ( _line ~ /^-/ ) {
            THEME_TAG_ITEM[ _tag L ] = i
            i=0
            _tag = substr(_line, 3)
            _tag_len = length(_tag)
            if (_tag != "all" )THEME_TAG[ ++THEME_TAG_L ] = _tag
            THEME_TAG[ THEME_TAG_L L ] = _tag_len
        } else {
            _theme = substr(_line, 5)
            _theme_len = length(_theme)
            ++i
            THEME_TAG_ITEM[ _tag i ]   = _theme
            if ( max_theme_len < _theme_len ) max_theme_len = _theme_len
        }
    }
    THEME_TAG_ITEM[ _tag L ] = i
    ctrl_rstate_init( SELECTED_THEME_TAG_IDX, 1, THEME_TAG_L )
}

function get_theme_preview( theme,          _cmd, i, c, _line){
    if (theme == "") return
    c = PREVIEW[theme]
    if ( c == "" ) {
        _cmd = "tar -f " THEME_TAR_PATH " -O -x style-preview/" theme " 2>/dev/null"
        for (i=1; _cmd | getline _line; i++) {
            c = c "\n" _line
        }
        gsub(/^[ \t\b\v\n]+/, "", c)
        gsub(/[ \t\b\v\n]+$/, "", c)
        PREVIEW[theme] = c
    }
}
# EndSection

# Section: cmd source

NR==1{
    try_update_width_height( $0 )
    ctrl_sw_init( IS_FOCUS_TAG, true )
    get_theme_arr()
    get_theme_tag()
    model_generate()
    CUR_THEME_IDX = ctrl_rstate_get( SELECTED_THEME_IDX )
    get_theme_preview( THEME_TAG_ITEM[ CUR_TAG 1] )
    view()
}

NR>1{
    if ( try_update_width_height( $0 ) )    next

    _cmd=$0
    gsub(/^C:/, "", _cmd)
    idx = index(_cmd, ":")
    ctrl(substr(_cmd, 1, idx-1), substr(_cmd, idx+1))
    if (ctrl_sw_get( IS_FOCUS_TAG ) == true) model_generate()
    CUR_THEME_IDX = ctrl_rstate_get( SELECTED_THEME_IDX )
    get_theme_preview(THEME_TAG_ITEM[ CUR_TAG CUR_THEME_IDX ])
    view()
}
# EndSection


END {
    if ( exit_is_with_cmd() == true ) {
        cur_theme = THEME_TAG_ITEM[ CUR_TAG CUR_THEME_IDX ]
        send_env( "___X_CMD_THEME_FINAL_COMMAND",    exit_get_cmd() )
        send_env( "___X_CMD_THEME_APP_FINAL_NAME",  cur_theme )
    }
}
