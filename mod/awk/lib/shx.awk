function shx(){

}

function shx_sleep( sec,    _cmd, a ){
    _cmd = "sleep " (sec=="" ? 1: sec)
    _cmd | getline a
    close( _cmd )
}

