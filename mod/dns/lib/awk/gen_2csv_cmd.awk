BEGIN{
    IS_LIST=0
    IS_DICT=0
    data = ""
    pre_key=""
}

function handle_dict(keypath,key,           key_l, _key, j, _data){
    # keypath = keypath SUBSEP key
    # _data = data "."key
    key_l = O[keypath L ]
    pre_key = pre_key "."key
    for(j=1; j<=key_l; ++j){
        _key = juq(O[ keypath SUBSEP  "\""j"\"" ])
        if (O[ keypath SUBSEP  "\""_key"\"" ] == "{"){
            handle_dict(keypath SUBSEP "\""_key"\"", _key )
            pre_key = pre_key "."key
        }
        else {
            _data = pre_key"."_key " "
            data = data _data
        }
        if( key_l == j)pre_key = ""
    }
}

function list(              key, i, len, keypath){
    len = O[kp("1", "1") L]
    for(i=1; i<=len; ++i){
        key = juq(O[kp("1", "1", i) ])
        keypath = SUBSEP "\"1\"" SUBSEP "\"1\"" SUBSEP "\""key"\""
        if (O[ keypath ] == "{") handle_dict(keypath, key)
        else if (key != "")data = data "."key " "
    }
}
function dict(        key, i, len, keypath){
    len = O[kp("1") L]
    for(i=1; i<=len; ++i){
        key = juq(O[kp("1", i) ])
        keypath = SUBSEP "\"1\""  SUBSEP "\""key"\""
        if (O[ keypath ] == "{") handle_dict(keypath, key)
        else if(key != "")data = data "."key " "
    }
}

END{
    if( O[kp("1")] == "[") IS_LIST = 1
    else IS_DICT = 1

    if (IS_LIST == 1) data = data "| x jo 2c "  ;   list()
    if (IS_DICT == 1) data = data "| x ja jl2c ";   dict()

    print data
}

