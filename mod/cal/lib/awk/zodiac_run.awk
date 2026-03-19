
{
    l = split($0, a, "[/-]")
    if (lang == "zh") {
        print( get_zodiac_name( a[l-1], a[l], 1 ) "座" )
    } else {
        print( get_zodiac_name( a[l-1], a[l] ) )
    }
}


