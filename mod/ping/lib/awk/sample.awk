
function sample_init(){
    sample_min  = 999
    sample_max  = 0

    sample_fail = 0
    sample_sum  = 0
}

function sample( v ){
    if (v == -1) {
        sample_fail ++
    } else {
        sample_data[ ++ sample_succ ] = v
        sample_sum = sample_sum + v
        if (v < sample_min) { sample_min = v };
        if (v > sample_max) { sample_max = v };
    }
}

function sample_report( v,   i , _stddev, _avg, _fmt ){
    _avg = (sample_succ == 0) ? 999 : (sample_sum / sample_succ)

    _stddev = 0
    for (i=1; i<=sample_succ; ++i) {
        d = sample_data[i] - _avg
        _stddev += d * d
    }
    _stddev = ( sample_succ == 0 ) ? 0 : ( _stddev / sample_succ )
    _stddev = sqrt( _stddev )

    if ( v == -1 )  M_SYMBOL = " ∉ "
    else            M_SYMBOL = " ∈ "

    _fmt = colrmap(v) "%7.3f ms" "\033[0m" M_SYMBOL
    _fmt = _fmt "[ " colrmapstr(sample_min, "%-3d") ", " colrmapstr(sample_max, "%3d")  " ]" " | "
    _fmt = _fmt "AVG = " colrmapstr(_avg, "%5.2f") " ± " "\033[2m" "%-7.2f " "\033[0m"

    return sprintf(_fmt,  v, sample_min, sample_max, _avg, _stddev)
}
