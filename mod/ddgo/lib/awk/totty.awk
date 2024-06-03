BEGIN{
    title            = ENVIRON[ "___X_CMD_CSV_APP_DATA_Title"        ]
    msg              = ENVIRON[ "___X_CMD_CSV_APP_DATA_Msg"          ]
    url              = ENVIRON[ "___X_CMD_CSV_APP_DATA_Url"          ]
    update           = ENVIRON[ "___X_CMD_CSV_APP_DATA_Update"       ]
    headline         = ENVIRON[ "___X_CMD_CSV_APP_DATA_AI_headline"  ]
    comment          = ENVIRON[ "___X_CMD_CSV_APP_DATA_AI_comment"   ]
    rating           = ENVIRON[ "___X_CMD_CSV_APP_DATA_AI_Mark"      ]


    printf("%sTitle%s: %s\n", UI_FG_CYAN,  UI_END, title)
    printf("%sMsg%s: |\n   %s\n", UI_FG_YELLOW,  UI_END, msg)
    printf("%sUrl%s: %s\n", UI_FG_GREEN,  UI_END, url)

    if(update != "") printf("%sUpdate%s: %s\n", UI_FG_BLUE,  UI_END, update)
    if(headline != "") printf("%sHeadline%s: %s\n", UI_FG_YELLOW,  UI_END, headline)
    if(comment != "") printf("%sComment%s: %s\n", UI_FG_CYAN,  UI_END, comment)
    if(rating != "") printf("%sRating%s: %s\n", UI_FG_RED,  UI_END, rating)

}