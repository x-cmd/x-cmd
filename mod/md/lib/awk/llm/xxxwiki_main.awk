

function hd_wiki_definition(){

}

function hd_wiki_main( arr,      i, l, line ){
    l = ARR_L
    arr[ ARR_I ] = 0
    while (arr[ ARR_I ]<=l) {
        i = arr[ ARR_I ]
        line = arr[i]
        if ( line ~ "^[-|*|_]{3,}[ ]*$" ) {
            gsub("^[-|*|_]{3,}[ ]*$", "----------", line)
            printf(HD_BLANK "%s\n", "\033[2m" line "\033[0m")
            larr_advance()
            continue
        }

        if ( line ~  "^\\{\\|")    { hd_wiki_table( line ); continue }   # handle table

        if ( line ~  "^=====[^=]+=====$")    { hd_head2( line ); continue }
        if ( line ~  "^====[^=]+====$")    { hd_head2( line ); continue }
        if ( line ~  "^===[^=]+===$")    { hd_head2( line ); continue }
        if ( line ~  "^==[^=]+==$")    { hd_head2( line ); continue }
        if ( line ~  "^=[^=]+=$")    { hd_head2( line ); continue }

        if ( line ~  "<syntaxhighlight[^>]+>")    { hd_wiki_codeblock( arr ); continue }

        if ( line ~  "<blockquote>[^<]+</blockquote>")    { hd_wiki_table( line ); continue }   # handle table

        # handle image ...

        if ( line ~ _regex_head( "#{3,6}" )) { hd_head3( line ); continue }

        if ( line ~ "^[ ]*```[A-Za-z0-9]+$" ) {
            hd_codeblock( arr )
            continue
        }

        # handle table, this is the most difficult
        # if ( line ~ "^```|(|)|$" ) {

        # }

        hd_body( arr )
    }

}

{
    arr[ ARR_L ++ ] = $0
}

END{
    printf("\n")
    hd_main( arr )
}