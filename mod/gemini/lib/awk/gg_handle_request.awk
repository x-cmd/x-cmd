BEGIN{
    data_str = str_trim( ENVIRON[ "question" ] )
    if (data_str == "") {
        exit(1)
    }

    provider = ENVIRON[ "provider" ]
    model = ENVIRON[ "model" ]
    toolstr = ", \"tools\": [{ \"google_search\": {} }]"
    if ( provider != "gemini" ) {
        toolstr = ""
        if ( model != "" ) modelstr = ", \"model\": \"" model "\""
    }

    print "{ \"contents\": [{ \"parts\": [{ \"text\": "jqu(data_str)" }] }] " modelstr toolstr "}"
}
