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
    if ( advise_get_ref_and_group(o, Q2_1, subcmd_group)) {
        l = subcmd_group[ L ]
        for (i=1; i<=l; ++i){
            k = subcmd_group[ i ]
            if ( ADVISE_DEV_TAG[ SUBSEP k ] == 1 ) continue
            ml = subcmd_group[ k L ]
            for (j=1; j<=ml; ++j) {
                mk = subcmd_group[ k, "\""j"\"" ]
                mod_name = juq( mk )
                sub( "\\|.*", "", mod_name )

                if ( ! check_is_mod_name(mod_name) ) continue
                mod_kp = Q2_1 SUBSEP mk
                mod_desc = o[ mod_kp, "\"#desc\"", "\"en\"" ]
                if (mod_desc == "") continue
                mod_desc = juq( mod_desc )

                comp_advise_get_ref(o, mod_kp)
                mod_tldr_kp = mod_kp SUBSEP "\"#tldr\""
                mod_tldr_l = o[ mod_tldr_kp L ]
                if ( mod_tldr_l > 0 ) tldr_str = " | "
                else tldr_str = ""
                for (tldr_id=1; tldr_id<=mod_tldr_l; ++tldr_id){
                    tldr_id_kp = mod_tldr_kp SUBSEP "\""tldr_id"\""
                    tldr_cmd = o[ tldr_id_kp, "\"cmd\"" ]
                    tldr_desc = aobj_get_value_with_local_language(o, tldr_id_kp, "\"en\"")
                    if (tldr_cmd == "") continue
                    tldr_str = tldr_str sprintf( "[(TLDR)%s]=`%s`\n", tldr_desc, tldr_cmd )
                }

                mod_desc = mod_desc tldr_str " | Use 'x " mod_name " --help' for more examples and instruction."
                gsub( "\n", " ", mod_desc )
                printf( "x-mod/%s\t%s\n", mod_name, mod_desc )
            }
        }
    }
}
