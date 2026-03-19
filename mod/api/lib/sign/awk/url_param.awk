BEGIN{
    result = ""
    param = ""
    AMPERSAND = "&"
    EQUAL = "="
}

{
    if( ($0 == "--X--") || ($0 == "") ){
        if ( (method == "POST&%2F&") ){
            tmp="true"
        }
        next
    }

    i = index($0, _x_cut)

    # ecs key urlencode ?
    key = urlencode(substr($0, 1, i-1))
    val = substr($0, i+1)
    if( tmp == "true" ){
        param = param ( (param == "") ? "" : " " ) "--data-urlencode " key EQUAL val
    }else{
        val = urlencode( val )
        result = result ( (result == "") ? "" : AMPERSAND ) key EQUAL val
    }
}
END{
    if (op == "ecs"){
        print "param_url=" shqu1( method urlencode( result ))
    }else{
        print "param_url=" shqu1(result);
    }
    if( param != "" ){
        print "_x_post_param=" shqu1(param);
    }
    if( signature != "" ){
        print "signature=" urlencode(signature)
    }
}