{
    cmd = $0
    cmd0 = $1

    if (cmd0map[ cmd0 ] == "") cmd0arr[ ++ cmd0arr[L] ] = cmd0
    cmd0map[ cmd0 ] ++

    if (cmdmap[ cmd ] == "") cmdarr[ ++ cmdarr[L] ] = cmd
    cmdmap[ cmd ] ++
}

END{
    for (i=1; i<=cmd0arr[L]; ++i) {
        cmd0 = cmd0arr[i]
        print cmd0map[cmd0], cmd0
        # print cmd0
    }
}
