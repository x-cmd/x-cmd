
function ___kill_init(){
    if (___KILL_INIT == 1) return
    ___KILL_INIT = 1

    SIGHUP      = signal[ "up" ]         = 1
    SIGINT      = signal[ "int" ]        = 2
    SIGQUIT     = signal[ "quit" ]       = 3
    SIGILL      = signal[ "ill" ]        = 4
    SIGTRAP     = signal[ "trap" ]       = 5

    SIGABORT    = signal[ "abrt" ]       = 6
    signal[ "abort" ] = signal[ "abrt" ]

    SIGFPE      = signal[ "fpe" ]        = 8
    SIGKILL     = signal[ "kill" ]       = 9

    # TODO: unix and linux is diffrent in kill signal
}

function kill( name, pid,   _cmd ){
    ___kill_init()

    if (name ~ /^[0-9]+$/)      _cmd = "kill -" name
    else                        _cmd = "kill -" signal[name]
    _cmd = _cmd " " pid
    _cmd | getline
    close(_cmd)
}
