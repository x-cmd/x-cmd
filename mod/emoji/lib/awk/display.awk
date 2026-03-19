BEGIN{
    if (name == "") NO_NAME = 1
    else HAS_NAME = 1
}

{
    LINE = $0
        if (LINE ~ "^# .*") LINE = tolower($0)
    if(NO_NAME == 1){
        if (match(LINE, "# group: ")) printf("\n%s %s\n" , $2 , tolower(substr(LINE,RLENGTH)))
        if(match(LINE, "# subgroup: ")) printf("  %s %s\n" , $2 , tolower(substr(LINE,RLENGTH)))
    }

    if(HAS_NAME == 1){

        if (match(LINE, "^# "name)) exit(0)
        if (match(LINE, "^# group: "name)){
            printf("\n%s\t%s\n" , $2 , tolower($3))
            SUBGROUP = 1
        }
    }

    if(SUBGROUP == 1){
        if(match(LINE, "# subgroup: ")) printf("  %s %s\n" , $2 , tolower($3))
    }
}