
function stdout_fastboot_env_tsv(               name, env_kp, path_kp, var_kp, i, l, key, val ){
    name = PKG_NAME
    sub( ".*/", "", name )

    env_kp  = jqu(PKG_NAME) SUBSEP "\"env\""
    path_kp = env_kp SUBSEP "\"path\""
    var_kp  = env_kp SUBSEP "\"var\""

    if ( table[ path_kp ] == "{" ) {
        if ( table[ path_kp, "\"unshift\""] == "[" ) {
            l = table[ path_kp, "\"unshift\"" L ]
            for (i=1; i<=l; ++i){
                printf( "%s\t%s\t%s\t%s\n", name, "path", "unshift", table_eval(table, PKG_NAME, table[ path_kp SUBSEP "\"unshift\"" SUBSEP "\""i"\"" ] ) )
            }
        }

        if ( table[ path_kp, "\"append\""] == "[" ) {
            l = table[ path_kp, "\"append\"" L ]
            for (i=1; i<=l; ++i){
                printf( "%s\t%s\t%s\t%s\n", name, "path", "append", table_eval(table, PKG_NAME, table[ path_kp SUBSEP "\"append\"" SUBSEP "\""i"\"" ] ) )
            }
        }
    }

    if ( table[ var_kp ] == "{" ) {
        l = table[ var_kp L ]
        for (i=1; i<=l; ++i){
            key = table[ var_kp, i ]
            val = table_eval(table, PKG_NAME, table[var_kp SUBSEP key] )
            printf( "%s\t%s\t%s\t%s\n", name, "var", juq(key), val )
        }
    }

}

END {
    if (PANIC_EXIT != 0) exit( PANIC_EXIT )
    stdout_fastboot_env_tsv()
}
