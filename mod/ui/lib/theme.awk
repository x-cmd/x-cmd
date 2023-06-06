BEGIN {
    TH_SEPERATOR = ""
    TH_INFO = ""
    TH_IMPORTANT = ""
    TH_ERROR = ""
    TH_NOT = ""

    TH_NORMAL_BEGIN = ""

    UI_END = "\033[0m"

    # All Variable Used in ui components will be placed here ...
    if ( TH_THEME_COLOR == "\033[m" ) TH_THEME_COLOR = UI_FG_CYAN

    # help
    TH_HELP                             =       TH_THEME_COLOR
    TH_CURSOR                           =       TH_THEME_COLOR UI_TEXT_REV UI_TEXT_BLINK

    # Section: form
    TH_FORM_Q_HELP                        =      UI_TEXT_DIM
    TH_FORM_Q_FALSE                       =      UI_FG_RED
    TH_FORM_Q_TRUE                        =      TH_THEME_COLOR

    TH_FORM_Q_FOCUSED   =  UI_TEXT_BOLD
    TH_FORM_Q_ARROW     =  TH_THEME_COLOR
    TH_FORM_Q_UNFOCUSED =  ""

    TH_FORM_A_FOCUSED_SELECTED                   =       UI_TEXT_REV TH_THEME_COLOR
    TH_FORM_A_FOCUSED_NOTSELECTED                =       UI_TEXT_DIM TH_THEME_COLOR
    TH_FORM_A_UNFOCUSED_SELECTED                 =       UI_TEXT_UNDERLINE TH_THEME_COLOR
    TH_FORM_A_UNFOCUSED_NOTSELECTED              =       UI_END
    # EndSection

    # Section: table
    TH_TABLE_HEADER_ITEM_NORMAL         =       UI_TEXT_UNDERLINE UI_TEXT_BOLD
    TH_TABLE_HEADER_ITEM_FOCUSED        =       UI_TEXT_UNDERLINE UI_TEXT_BOLD  TH_THEME_COLOR
    TH_TABLE_LINE_ITEM_FOCUSED          =       ""
    TH_TABLE_SELECTED_COL               =       TH_THEME_COLOR
    TH_TABLE_SELECTED_ROW               =       UI_TEXT_REV
    TH_TABLE_SELECTED_ROW_COL           =       UI_TEXT_BOLD
    # EndSection

    # Section: gridselect
    TH_GRIDSELECT_HEADER_NORMAL           =       ""
    TH_GRIDSELECT_ITEM_FOCUSED            =       TH_THEME_COLOR
    TH_GRIDSELECT_ITEM_UNFOCUSED          =       ""
    TH_GRIDSELECT_ITEM_SELECTED           =       UI_TEXT_BOLD
    TH_GRIDSELECT_ITEM_UNSELECTED         =       ""
    TH_GRIDSELECT_ITEM_SELECTED_INFO      =       TH_THEME_COLOR
    TH_GRIDSELECT_ITEM_ICON               =       UI_FG_GREEN
    TH_GRIDSELECT_ITEM_UNICON             =       UI_FG_DARKGRAY
    # EndSection

    # Section: selectn
    TH_SELECTN_HEADER_NORMAL            =       UI_TEXT_UNDERLINE
    TH_SELECTN_ITEM_FOCUSED_SELECT      =       UI_TEXT_BOLD UI_FG_GREEN UI_TEXT_REV
    TH_SELECTN_ITEM_FOCUSED_UNSELECT    =       UI_TEXT_BOLD UI_TEXT_REV UI_FG_BLUE
    TH_SELECTN_ITEM_UNFOCUSED_SELECT    =       UI_TEXT_UNDERLINE UI_FG_GREEN
    TH_SELECTN_ITEM_UNFOCUSED_UNSELECT  =       ""
    # EndSection

    # Section: categoryselect
    TH_CATEGORYSELECT_HEADER_NORMAL            =       UI_TEXT_UNDERLINE
    TH_CATEGORYSELECT_UNDIRECTORY              =       UI_TEXT_DIM
    TH_CATEGORYSELECT_ITEM_FOCUSED_SELECT      =       UI_TEXT_BOLD UI_FG_GREEN UI_TEXT_REV
    TH_CATEGORYSELECT_ITEM_FOCUSED_UNSELECT    =       UI_TEXT_BOLD UI_TEXT_REV UI_FG_BLUE
    TH_CATEGORYSELECT_ITEM_UNFOCUSED_SELECT    =       UI_FG_GREEN
    TH_CATEGORYSELECT_ITEM_UNFOCUSED_UNSELECT  =       ""
    TH_CATEGORYSELECT_ITEM_UNFOCUSED_UNGRIDSELECT_DIR  =   UI_TEXT_UNDERLINE
    # EndSection

    # Section: catsel
    TH_CATSEL_INFO                     =       TH_THEME_COLOR
    TH_CATSEL_INFO_KEY                 =       UI_TEXT_BOLD TH_THEME_COLOR
    TH_CATSEL_DIRECTORY                =       TH_THEME_COLOR
    TH_CATSEL_ITEM_FOCUSED_SELECT      =       UI_TEXT_BOLD UI_TEXT_REV TH_THEME_COLOR
    TH_CATSEL_ITEM_FOCUSED_UNSELECT    =       UI_TEXT_BOLD
    TH_CATSEL_ITEM_UNFOCUSED_SELECT    =       UI_TEXT_BOLD
    TH_CATSEL_ITEM_UNFOCUSED_UNSELECT  =       UI_TEXT_DIM
    # EndSection

    # Section: lsenv
    TH_LSENV_INFO                     =       TH_THEME_COLOR
    TH_LSENV_HEADER                   =       UI_TEXT_UNDERLINE
    TH_CATSEL_DIRECTORY               =       TH_THEME_COLOR
    TH_LSENV_ITEM_FOCUSED_SELECT      =       UI_TEXT_BOLD UI_TEXT_REV TH_THEME_COLOR
    TH_LSENV_ITEM_FOCUSED_UNSELECT    =       UI_TEXT_BOLD
    TH_LSENV_ITEM_UNFOCUSED_SELECT    =       UI_TEXT_BOLD
    TH_LSENV_ITEM_UNFOCUSED_UNSELECT  =       UI_TEXT_DIM
    # EndSection

    # Section: theme app
    TH_THEME_PREVIEW_FOCUSE = TH_THEME_COLOR
    TH_THEME_PREVIEW_SELECT = UI_TEXT_REV
    # EndSection

    # help panel

    # Status line   # ...
    TH_STATUSLINE_TEXT                 =       ""
    TH_DATA_UNFIND                     =       UI_TEXT_DIM
}

# Section: statusline help
function th_statusline_text( text ){
    return TH_STATUSLINE_TEXT text UI_END
}

function th_help_text( text ){
    return TH_HELP text UI_END
}

# EndSection

# Section: qa
function th_qa_answer_valid( text ){
    return TH_ANSWER_VALID text UI_END
}

function th_qa_answer_invalid( text ){
    return TH_ANSWER_INVALID text UI_END
}

function th_qa_answer( text ){
    return TH_ANSWER text UI_END
}


# EndSection
