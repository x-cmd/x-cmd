
# best effort
function fix_consume_arg( aobj, kp, args, i,      e ) {
    e = args[i]
    if (fix_consume_subcmd( aobj, kp, args, i )) {
        return
    }

    if (fix_consume_opt2( aobj, kp, args, i )) {
        return
    }

    if (fix_consume_opt1( aobj, kp, args, i )) {
        return
    }

    # is close to subcmd ?
    # is close to opt2 ?
    # is close to opt1 ?
    # provide a another command ...
}

function fix_consume_subcmd( aobj, kp, args, i ) {

}

function fix_consume_opt2( aobj, kp, args, i ) {

}

function fix_consume_opt1( aobj, kp, args, i ) {

}
