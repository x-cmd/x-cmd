
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
    # TODO: Implement subcommand consumption logic
}

function fix_consume_opt2( aobj, kp, args, i ) {
    # TODO: Implement long option consumption logic
}

function fix_consume_opt1( aobj, kp, args, i ) {
    # TODO: Implement short option consumption logic
}
