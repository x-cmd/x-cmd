BEGIN {
    ___X_CMD_CMD_IDX = 0
}

function cmd( text ){
    return ": " (++___X_CMD_CMD_IDX) " ; " text
}

function cmd_sleep( sec ){
    cmd( "sleep " sec )
}

function cmd_sh( work ){
    return cmd("/bin/sh -c ", shqu(work) )
}

function cmd_ls( opt ){
    return cmd("ls " opt )
}

function cmd_outerr( c ){
    return cmd("___x_cmd_awk_cmd_wrapouterr(){" c " }; x outerr ___x_cmd_awk_cmd_wrapouterr")
}

