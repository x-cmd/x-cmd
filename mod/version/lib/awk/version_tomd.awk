function parse_changelog(O, version, key,       i, j, h, len, _len, __len, key_k, key_t, value){
    len = O[ kp("1", version, key) L ]
    for (i=1; i<=len; ++i)  {
        key_k = O[ kp("1", version, key, i) ]
        _len = O[ kp("1", version, key, juq(key_k) ) L ]
        printf("%s%s\n\n", "## ", juq(key_k))

        for (j=1; j<=_len; ++j) {
            key_t = O[kp("1", version, key, juq(key_k), j)]
            __len = O[ kp("1", version, key, juq(key_k), juq(key_t)) L ]

            for (h=1; h<=__len; ++h) {
                value = O[ kp("1", version, key, juq(key_k), juq(key_t), h, "en") ]
                gsub(/\\n/, "\n", value)
                printf("%s%s\n", "  - ", juq(value))
            }
        }
        printf "\n"
    }
}

END{
    l = O[ kp("1") L ]
    for(i=1; i<=l; ++i){
        if( version == juq(O[ kp("1", i) ]) ) {
            previous_version = juq(O[ kp("1", i+1) ])
            _l = O[ kp("1", version) L ]
            for(j=1; j<=_l; ++j){
                key = juq(O[ kp("1", version, j)])
                change[ key ] = O[ kp("1", version, key)]
            }
        }
    }

    if( ( change[ "blog" ] != "null" ) && ( change[ "blog" ] != "" ) ) {
        printf("%s%s\n", "[👉 View X-CMD demo for more information about this version]", "(https://x-cmd.com" juq(change[ "blog" ]) ")" )
    }

    if( previous_version != "" ) {
        compare = previous_version "..." version
        printf("%s%s\n\n", "[👉 Version compare: " compare "]", "(https://github.com/x-cmd/x-cmd/compare/" compare ")" )
    }

    if( change[ "latest" ] == "true" )   printf("%s\n\n%s\n\n", "# ✅Upgrade Guide", "```bash \nx upgrade \n```")

    if( change[ "change" ] != "" ) {
        printf("%s\n\n", "# 📃Changelog")
        parse_changelog(O, version, "change")
    }
}
