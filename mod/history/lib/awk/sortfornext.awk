

function sortfornext( cmd, result,   _histcmdarr, _freq, _nextcand, i, j, _uniql ) {
    while (getline d) {
        if (cmd == _histcmdarr[ l ]) {
            if (_nextcand[ d ] == "") {
                _nextcandarr[ _nextcandarr[ L ] ++ ] = d
            }
            _nextcand[ d ] ++
        }

        _histcmdarr[ _histcmdarr[ L ] ++ ] = d

        if (_freq[d] == "")  _uniql++
        _freq[ d ] += 1
    }

    for (j in _nextcand) {
        if (_nextcand[ j ] > 5)         _result[ _result[L] ++ ] = j
    }

    for (i=5; i>0; i--) {
        for (j in _nextcand) {
            if (_nextcand[ j ] == i)    _result[ _result[L] ++ ] = j
        }
    }
}

BEGIN{
    sortfornext( ENVIRON[ "cmd" ], result )
    for (i=1; i<=result[L]; ++i) print result[i]
}


