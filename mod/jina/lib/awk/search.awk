
BEGIN{
    true = 1
}

function parse_jina_search_print( _title, _url, _content ){
    printf("- %s: |\n    %s\n", "title", _title)
    printf("  %s: |\n    %s\n", "url", _url)
    printf("  %s: |%s\n",  "markdown", _content )
}

function parse_jina_search(     _title, _url, _markdown_content, _content, i ){
    i = 0

    getline
    while (true) {
        _title = $0
        gsub("^[^:]+:[ ]", "", _title)
        getline _url
        gsub("^[^:]+:[ ]", "", _url)
        getline _markdown_content

        _content = ""
        while (true) {
            if (! getline){
                parse_jina_search_print( _title, _url, _content )
                return
            }

            if ($0 ~ "^\\[[0-9]+\\][ ]Title:") break
            _content = _content "\n    " $0
            # Future TODO: add two line speration
        }

        parse_jina_search_print( _title, _url, _content )
    }
}

BEGIN{
    parse_jina_search()
}
