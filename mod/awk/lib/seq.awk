
function seq( seqstr, a,    i, j ){
    seq_parse( seqstr )
    for (i=SEQ_BEGIN; i<=SEQ_END; i+=SEQ_DELTA) a[ ++j ] = i
}

function seq_parse(  seqstr,       l, a, b, e, d ){
    l = split(seqstr, a, ":")
    if (l == 1)      {          SEQ_BEGIN =   1 ;   SEQ_DELTA =   1 ;   SEQ_END = a[1];     }
    else if (l == 2) {          SEQ_BEGIN = a[1];   SEQ_DELTA =   1 ;   SEQ_END = a[2];     }
    else             {          SEQ_BEGIN = a[1];   SEQ_DELTA = a[2];   SEQ_END = a[3];     }
}

function seq_within( number, seqstr ){
    seq_parse( seqstr )
    return ( (number >= SEQ_BEGIN) && (number <= SEQ_END) && ( 0 == (number - SEQ_BEGIN) % SEQ_DELTA ) )
}
