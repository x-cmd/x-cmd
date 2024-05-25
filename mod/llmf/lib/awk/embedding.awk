BEGIN{
    content = ENVIRON[ "raw_content" ]
    printf("{\"content\": %s}", jqu(content))
}

