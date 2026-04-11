
BEGIN{
    SPDB_PREFIX = ENVIRON[ "SPDB_PREFIX" ]
    SPDB_COUNT = ENVIRON[ "SPDB_TRIGGER_COUNT" ] || 10000

    jsonkey = ENVIRON[ "SPDB_JSONKEY" ]
}

function spdb_consumer_init_topic( topic , _name ){
    SPDB_CURRENT_NAME_ARR[ topic ] = spdb_getnextfp( _name = (SPDB_PREFIX "." topic) )
    SPDB_CURRENT_COUNT_ARR[ topic ] = 0
    return _name
}

function spdb_consumer_consume_by_jsonkey( keyname, msg,    _topic, _arr, _count, _name ){
    match( msg, "(\"" keyname "\")[ ]+:[^},]+"  )
    _topic = substr( msg, RSTART, RLENGTH )
    split( _topic , _arr , ":" )
    _topic = _arr[2]
    gsub( "(^[ ]+\")|(\"[ ]+$)", "", _topic )

    _count = SPDB_CURRENT_COUNT_ARR[ _topic ] || 0
    _name = SPDB_CURRENT_NAME_ARR[ _topic ]

    if (_count == 0){
        _name = spdb_consumer_init_topic( )
    } else if ( _count >= SPDB_TRIGGER_COUNT ) {
        close( _name )
        _name = spdb_consumer_init_topic( _topic )
    }

    printf("%s\n", msg) >>_name
    fflush( _name )
}

{
    spdb_consumer_consume_by_jsonkey( jsonkey, $0 )
}
