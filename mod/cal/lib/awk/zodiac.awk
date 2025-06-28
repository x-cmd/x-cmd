BEGIN{
    ZODIAC_NAME[1, 0] = "Aries"
    ZODIAC_NAME[1, 1] = "白羊"

    ZODIAC_NAME[2, 0] = "Taurus"
    ZODIAC_NAME[2, 1] = "金牛"

    ZODIAC_NAME[3, 0] = "Gemini"
    ZODIAC_NAME[3, 1] = "双子"

    ZODIAC_NAME[4, 0] = "Cancer"
    ZODIAC_NAME[4, 1] = "巨蟹"

    ZODIAC_NAME[5, 0] = "Leo"
    ZODIAC_NAME[5, 1] = "狮子"

    ZODIAC_NAME[6, 0] = "Virgo"
    ZODIAC_NAME[6, 1] = "处女"

    ZODIAC_NAME[7, 0] = "Libra"
    ZODIAC_NAME[7, 1] = "天秤"

    ZODIAC_NAME[8, 0] = "Scorpio"
    ZODIAC_NAME[8, 1] = "天蝎"

    ZODIAC_NAME[9, 0] = "Sagittarius"
    ZODIAC_NAME[9, 1] = "射手"

    ZODIAC_NAME[10, 0] = "Capricorn"
    ZODIAC_NAME[10, 1] = "摩羯"

    ZODIAC_NAME[11, 0] = "Aquarius"
    ZODIAC_NAME[11, 1] = "水瓶"

    ZODIAC_NAME[12, 0] = "Pisces"
    ZODIAC_NAME[12, 1] = "双鱼"
}

function get_zodiac_name( m, d,  lang ) {
    if (lang == "") lang = 0  # En
    if ((m == 3 && d >= 21) || (m == 4 && d <= 19))     return ZODIAC_NAME[  1, lang ]
    if ((m == 4 && d >= 20) || (m == 5 && d <= 20))     return ZODIAC_NAME[  2, lang ]
    if ((m == 5 && d >= 21) || (m == 6 && d <= 21))     return ZODIAC_NAME[  3, lang ]
    if ((m == 6 && d >= 22) || (m == 7 && d <= 22))     return ZODIAC_NAME[  4, lang ]
    if ((m == 7 && d >= 23) || (m == 8 && d <= 22))     return ZODIAC_NAME[  5, lang ]
    if ((m == 8 && d >= 23) || (m == 9 && d <= 22))     return ZODIAC_NAME[  6, lang ]
    if ((m == 9 && d >= 23) || (m == 10 && d <= 23))    return ZODIAC_NAME[  7, lang ]
    if ((m == 10 && d >= 24) || (m == 11 && d <= 22))   return ZODIAC_NAME[  8, lang ]
    if ((m == 11 && d >= 23) || (m == 12 && d <= 21))   return ZODIAC_NAME[  9, lang ]
    if ((m == 12 && d >= 22) || (m == 1 && d <= 19))    return ZODIAC_NAME[ 10, lang ]
    if ((m == 1 && d >= 20) || (m == 2 && d <= 18))     return ZODIAC_NAME[ 11, lang ]
    if ((m == 2 && d >= 19) || (m == 3 && d <= 20))     return ZODIAC_NAME[ 12, lang ]
    return "Unknown"
}
