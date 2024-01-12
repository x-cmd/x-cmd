

function predict( cmd, result,      _histcmdarr, _freq, _nextcand, _nextcandarr, d, l, i, j, _uniql ) {
    cmd = str_trim(cmd)
    while (getline d) {
        d = str_trim(d)
        if (cmd == _histcmdarr[ l ]) {
            if (_nextcand[ d ] == "") {
                _nextcandarr[ ++ _nextcandarr[ L ] ] = d
            }
            _nextcand[ d ] ++
        }

        l = ++ _histcmdarr[ L ]
        _histcmdarr[ l ] = d

        if (_freq[d] == "")  _uniql++
        _freq[ d ] += 1
    }

    for (j in _nextcandarr) {
        d = _nextcandarr[ j ]
        if (_nextcand[ d ] > 5)         result[ ++ result[L] ] = d
    }

    for (i=5; i>0; i--) {
        for (j in _nextcandarr) {
            d = _nextcandarr[ j ]
            if (_nextcand[ d ] == i)    result[ ++ result[L] ] = d
        }
    }
}

BEGIN{
    predict( ENVIRON[ "cmd" ], result )

    size = int( ENVIRON[ "size" ] )
    l = result[L]
    if (size > 0) l = (( l > size ) ? size : l)
    for (i=1; i<=l; ++i) print result[i]
}


