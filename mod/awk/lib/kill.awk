
BEGIN {
    ___KILL_INIT = 0
}

function ___kill_init(){
    if (___KILL_INIT == 1) return

    SIGHUP = signal[ "up" ]         = 1
    SIGINT = signal[ "int" ]        = 2
    SIGINT = signal[ "quit" ]       = 3
    SIGINT = signal[ "ill" ]        = 4
    SIGINT = signal[ "trap" ]       = 5
    SIGINT = signal[ "abrt" ]       = 6

    signal[ "abort" ] = signal[ "abrt" ]

    SIGINT = signal[ "fpe" ]        = 8
    SIGINT = signal[ "kill" ]       = 9

    # Find out which system is, using the
}

function kill( name, pid,   cmd ){
    ___kill_init()

    if (name ~ /[0-9]+/)    cmd = "kill -" name
    else                    cmd = "kill -" signal[name]
    cmd = cmd " " pid
    cmd | getline
    close(cmd)
}
