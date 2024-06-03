BEGIN{
    content = ENVIRON[ "raw_content" ]
    flileist = ENVIRON[ "flileist" ]
    url = ENVIRON[ "url" ]
    res = gen_post_content(flileist, content)

    printf("%s", res)
    # printf("{\"content\": %s}", jqu(content))
}

function gen_post_content(flileist, content,    arr, i, l, _str, fp, _res){
    flileist = str_trimspace(flileist)

    l = split(flileist, arr, "\n")
    for (i=1; i<=l; ++i){
        fp = arr[i]
        if (fp == "") continue
        _str = cat(fp)
        _str = sprintf("{\"content\": %s}", jqu(_str))
        _res = _res " -X POST " url " -H \"Content-Type: application/json\" -d '" _str "'"
       if(i < l) _res = _res "  --next "
    }

    if(content != "") {
        if (_res != "") _res = _res "  --next "
        _str = sprintf("{\"content\": %s}", jqu(content))
        _res = _res " -X POST " url " -H \"Content-Type: application/json\" -d '" _str "'"
    }
    _res = " ___x_cmd curl" _res
    return  _res
}

function str_trimspace( s ){  gsub(/[ \t\n]+$/, "", s); return s; }