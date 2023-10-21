# END{
#     amount =  O[ L ]
#     for(i=1; i<=amount; ++i){
#         KP = SUBSEP "\""i"\""
#         get_install_cmd(O, KP)
#     }
# }

function get_install_cmd(O,          j, k, len, key,  rule_len, rule_key,arr, arg, cmd){
    ARG = tolower(ARG)
    kp = SUBSEP "\""1"\""
    len = O[ kp  L]
    for(j=1; j<=len; ++j){
        rule_key = juq(O[ kp S j ])
        if(rule_key =="rule"){
            rule_len = O[ kp S "\""rule_key"\"" L ]
            kp = kp S "\""rule_key"\""
            for(k=1; k<=rule_len; ++k){
                key = juq(O[ kp S k ])
                split(key , arr, "/")
                split(ARG , arg, "/")
                cmd = juq(O[ kp S "\""key"\"" S "\"cmd\"" ])
                reference = juq(O[ kp S "\""key"\"" S "\"reference\"" ])
                if( (arr[1] == arg[1]) && (arr[2] == arg[2]))   print_install_cmd_style(cmd, reference, install_name)
                else if ( (arr[1] == arg[1]) && (arg[2] == "")) print_install_cmd_style(cmd, reference, install_name)
                else if ( (arg[1] == "") && (arr[2] == arg[2])) print_install_cmd_style(cmd, reference, install_name)
            }
        }
    }
}
