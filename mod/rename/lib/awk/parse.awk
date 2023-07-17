
BEGIN{
    # print "pat: \t" pat  >"/dev/stderr"
    while (match(pat, /%\{[a-z]+\}/)) {
        leading[ ++parr[L] ] = substr(pat, 1, RSTART-1)
        variable[ parr[L] ] = substr(pat, RSTART+2, RLENGTH-3)

        # print leading[ parr[L] ] "\t" variable[ parr[L] ] >"/dev/stderr"
        pat = substr(pat, RSTART+RLENGTH)
    }

    leading[ ++ parr[L]] = pat
}

{
    print $0
    delete res

    str = $0
    for (i=1; i<parr[L]; i++) {
        if (substr(str, 1, length(leading[i])) != leading[i]) {
            print 0
            next
        }

        str = substr(str, length(leading[i])+1)
        if ( (idx = index(str, leading[i+1]) ) >= 2) {
            res[ variable[i] ] = substr(str, 1, idx-1)
            # print str "\t" idx "\t" substr(str, 1, idx-1)>"/dev/stderr"
            str = substr(str, idx)
        } else {
            print 0
            next
        }
    }

    if (str != leading[i]) {
        print 0
        next
    }

    print length(res)
    for (var in res) {
        print var "='" res[var] "';"
    }
}
