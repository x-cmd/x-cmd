# linux: date -d '2022-11-09 12:31:27+00:00' +%s

function date_to_timestamp_linux( date,     t, _cmd ){
    _cmd = "date  +%s -ud '" date "' 2>/dev/null"
    _cmd | getline t
    close( _cmd )
    return t
}

# macos: date -j -f "%Y-%m-%d %H:%M:%S%z" "2022-11-09 12:31:27+0000" "+%s"
# macos: date -j -f "%Y-%m-%d %H:%M:%S" "2022-11-09 12:31:27" "+%s"
function date_to_timestamp_bsd( date,       t, _cmd ) {
    if (date ~ /:[0-9][0-9]$/) {
        date = substr(date, 1, length(date)-3) substr(date, length(date)-1)
    }
    _cmd = "date -j -f \"%Y-%m-%d %H:%M:%S%z\" \"" date "\" +%s 2>/dev/null"
    _cmd | getline t
    close( _cmd )
    return t
}

function date_to_timestamp( date,   t ){
    return ( (t = date_to_timestamp_linux( date ) ) != "") ? t : date_to_timestamp_bsd( date )
}


function timestamp_to_date_linux( timestamp,   t, _cmd ){
    _cmd = "date \"+%Y-%m-%d %H:%M:%S\" -ud @'"timestamp"' 2>/dev/null"
    _cmd | getline t
    close( _cmd )
    return t
}

function timestamp_to_date_bsd( timestamp,   t, _cmd ){
    _cmd = "date -ur \"" timestamp "\" \"+%Y-%m-%d %H:%M:%S\"  2>/dev/null"
    _cmd | getline t
    close( _cmd )
    return t
}

function timestamp_to_date( timestamp,   t ){
    return ( (t = timestamp_to_date_linux( timestamp ) ) != "") ? t : timestamp_to_date_bsd( timestamp )
}

function date_epochminus(a, b,          c){
    c = sprintf("%.3f", a - b)
    gsub(/0+$/, "", c)
    gsub(/\.$/, "", c)
    return c
}

function date_humantime(t,          _res) {
    _res = (t % 60) "s"
    t = int(t)
    if (t >= 60) {
        _res = int((t / 60) % 60) "m " _res
        if (t >= 3600) {
            _res = int((t / 3600) % 24) "h " _res
            if (t >= 86400) {
                _res = int(t / 86400) "d " _res
            }
        }
    }
    return _res
}
