# linux: date -d '2022-11-09 12:31:27+00:00' +%s

function date_to_timestamp_linux( date,   t, _cmd){
    _cmd = "date  +%s -ud '" date "'" " 2>/dev/null"
    _cmd | getline t
    # close(cmd)
    return t
}

# macos: date -j -f "%Y-%m-%d %H:%M:%S%z" "2022-11-09 12:31:27+0000" "+%s"
# macos: date -j -f "%Y-%m-%d %H:%M:%S" "2022-11-09 12:31:27" "+%s"
function date_to_timestamp_bsd( date,  t ) {
    if (date ~ /:[0-9][0-9]$/) {
        date = substr(date, 1, length(date)-3) substr(date, length(date)-1)
    }
    "date -j -f \"%Y-%m-%d %H:%M:%S%z\" \"" date "\" +%s 2>/dev/null" | getline t
    return t
}

function date_to_timestamp( date,   t ){
    return ( (t = date_to_timestamp_linux( date ) ) != "") ? t : date_to_timestamp_bsd( date )
}
