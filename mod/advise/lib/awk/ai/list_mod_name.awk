BEGIN{
    ___X_CMD_ROOT_ADV = ENVIRON[ "___X_CMD_ROOT_ADV" ]
}

function check_is_mod_name(name,        fp, c ){
    fp = ___X_CMD_ROOT_ADV "/" name "/advise.jso"
    fp = filepath_adjustifwin( fp )
    c=(getline <fp)
    # debug( "c:" c " fp:" fp )
    close( fp )
    if (c == -1) return false
    return true
}

{ if ($0 != "") jiparse_after_tokenize(o, $0); }
END{
    Q2_1 = SUBSEP "\"1\""
    if ( advise_get_ref_and_group(o, Q2_1)) {
        l = o[ Q2_1 L ]
        for (i=1; i<=l; ++i){
            k = juq( o[ Q2_1, i ])
            if (( k ~ "^#" ) || (k ~ "\\|")) continue
            if ( check_is_mod_name(k) ) print k
        }
    }
}
