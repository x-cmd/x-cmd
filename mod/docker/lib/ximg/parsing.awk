$0~"^[ \t\v]*#"{
    if (match($0, /x-cmd.from:/) || match($0, /x-cmd.FROM:/)) {
        from = substr($0, RSTART+RLENGTH)
        gsub("(^[ \t\v]+)|([ \t\v]+$)", "", from)
        next
    }

    if (match($0, /x-cmd.entrypoint:/) || match($0, /x-cmd.ENTRYPOINT:/)) {
        entrypoint = substr($0, RSTART+RLENGTH)
        gsub("(^[ \t\v]+)|([ \t\v]+$)", "", entrypoint)
        next
    }

    if (match($0, /x-cmd.fp:/) || match($0, /x-cmd.FP:/)) {
        fp = substr($0, RSTART+RLENGTH)
        gsub("(^[ \t\v]+)|([ \t\v]+$)", "", fp)
        next
    }

    next
}

$0~"^[ \t\v]*$"{
    next
}

{
    hascode=1
}

function shq( s ){
    gsub("'", "'\\''", s)
    return "'" s "'"
}

END{
    if (hascode != 1) {
        if (entrypoint != "") {
            print("type=nocode-entrypoint")
        } else {
            print("type=nocode")
        }
    }

    if (entrypoint!="") printf("entrypoint=%s\n",   shq(entrypoint))
    if (fp!="")         printf("fp=%s\n",           shq(fp))
    if (from!="")       printf("from=%s\n",         shq(from))
}

