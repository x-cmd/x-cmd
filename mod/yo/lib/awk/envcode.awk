BEGIN{
    envkp[ L ] = arrl = split(ENVIRON["argstr"], arr, "\001")
    for (i=2; i<=arrl; ++i) {     # Notice: first line is empty
        str_divide_( arr[i], "=" )
        envname[ i ]  = x_1
        envkp[ i ]    = normalize_kp( x_2 )
    }
}

($0 != ""){ jiparse_after_tokenize(o, $0); }

END{
    for (i=2; i <= envkp[ L ]; ++i)  printf( "%s=%s\n", envname[ i ], o[ envkp[ i ] ] )
}
