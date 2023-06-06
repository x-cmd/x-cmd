
function cursor_goto(row, column){
    return "\033[" row ";" column "dh"
}

function cursor_save(){
    return UI_CURSOR_SAVE
}

function cursor_restore(){
    return UI_CURSOR_RESTORE
}

function cursor_move(row, column){
    return "\033[" row ";" column "dh"
}

function cursor_move_down( number ){
    return "\033[" number "D"
}

function cursor_move_up( number ){
    return "\033[" number "A"
}

function cursor_move_left( left ){
    return "\033[" number "A"
}

function cursor_move_right( right ){
    return "\033[" number "A"
}
