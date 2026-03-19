BEGIN{
    printf( "%s,%s,%s\n", "hash", "type", "size" )
}

$2=="commit"{
    blob_id = $1
    all[ blob_id ] = "commit"

    commit[ blob_id, "size" ] = $3
    print_data()
    # commit[ blob_id, "size-in-packfile" ] = $4
    # commit[ blob_id, "offset--in-packfile" ] = $5
}

$2=="tree"{
    blob_id = $1
    all[ blob_id ] = "tree"

    commit[ blob_id, "size" ] = $3
    print_data()
    # commit[ blob_id, "size-in-packfile" ] = $4
    # commit[ blob_id, "offset--in-packfile" ] = $5
}

$2=="blob"{
    blob_id = $1
    all[ blob_id ] = "blob"

    commit[ blob_id, "size" ] = $3
    print_data()
    # commit[ blob_id, "size-in-packfile" ] = $4
    # commit[ blob_id, "offset--in-packfile" ] = $5
}

function print_data(){
    printf( "%s,%s,%s\n", blob_id,  all[ blob_id ] , commit[ blob_id, "size" ] )
}