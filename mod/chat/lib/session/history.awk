
function minion_parse_history_json( o, prefix,  history_fp ){

}

function minion_get_history( history, dir, _cmd ){
    _cmd = "/bin/ls " dir " | /bin/sort -r"

    while( ( _cmd | getline ) > 0 ){

        history_req_fp = filedir "/req.json"  # request.json
        history_res_fp = filedir "/res.json"  # response.json
        history[ $0 ] = 1
    }

    close( _cmd )
}

{

}

# define

#

