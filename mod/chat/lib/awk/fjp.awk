{ jiparse_after_tokenize(o, $0); }

END{
    filelist = ENVIRON[ "filelist" ]
    jsontofile(o, filelist)
}

function jsontofile(o, filelist,      l, i, _) {
    l = split(filelist, _, "\n")
    for (i=1; i<l; ++i){
        print jstr(o, S "\"1\"" S "\""i"\"") > _[i]
    }
}
