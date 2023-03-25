BEGIN{ FS = "=" }

match($0, "^" PREFIX "[^=]*=") || (STATE != "") {
    LINE = (LINE == "") ? $0 : (LINE "\n" $0)

    if (STATE == "") {
        KEY = $1
        $0 = substr($0, RLENGTH+1)
        STATE = substr($0, 1, 1)
        $0 = substr($0, 2)
        if (STATE != "'") {
            finish()
            next
        }
    }

    if (STATE == "'") {
        gsub("'\\\\''", "", $0)
        gsub("'\"'+\"'", "", $0)
        if (substr($0, length($0)) == "'")  finish()
    }
}

function finish(){
    if (TYPE == "key")  print KEY
    else                print LINE
    LINE = ""
    STATE = ""
}

