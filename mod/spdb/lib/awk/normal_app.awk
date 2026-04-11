
BEGIN{
    SPDB_PREFIX = ENVIRON[ "SPDB_PREFIX" ]
    SPDB_COUNT = ENVIRON[ "SPDB_TRIGGER_COUNT" ] || 10000

    jsonkey = ENVIRON[ "SPDB_JSONKEY" ]
}

function spdb_consumer_init( ){
    SPDB_CURRENT_NAME = spdb_getnextfp( SPDB_PREFIX )
    SPDB_CURRENT_COUNT = 0
}

function spdb_consumer_consume( msg ){
    if ( SPDB_CURRENT_COUNT >= SPDB_TRIGGER_COUNT ) {
        close(SPDB_CURRENT_NAME)
        spdb_consumer_init()
    }

    printf("%s\n", msg) >>SPDB_CURRENT_NAME
    fflush( SPDB_CURRENT_NAME )
}

{
    spdb_consumer_consume( $0 )
}
