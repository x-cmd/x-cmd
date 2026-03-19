BEGIN{
    RAW_DATA        = ENVIRON[ "RAW_DATA" ]
    AI_DATA         = 0
}


$0 == "```json"{ AI_DATA = 1; next }

AI_DATA == 1{
    if ($1 == "```") exit(0)
    printf("%s", $0)
}


RAW_DATA == 1{ if($0 == "Title,Msg,Url,Update") PRINT_DATA = 1 }
PRINT_DATA == 1 { printf("%s\n", $0)}
