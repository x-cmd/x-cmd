BEGIN{
    data_str = str_trim( ENVIRON[ "question" ] )
    if (data_str == "") {
        exit(1)
    }

    print "{ \"contents\": [{ \"parts\": [{ \"text\": "jqu(data_str)" }] }], \"tools\": [{ \"google_search\": {} }] }"
}