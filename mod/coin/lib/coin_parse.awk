BEGIN{
    OFS=","
    printf( "%s,%s,%s,%s,%s,%s,%s\n", "Name", "Price", "MarketCap", "VWAP(24Hr)", "Supply", "Volume(24Hr)", "Change(24Hr)")
}

function number_parse(item){
    result=""
    if (item >= 1e12) {
        result = sprintf("%.2ft", item/1e12);
    } else if (item >= 1e9) {
        result = sprintf("%.2fb", item/1e9);
    } else if (item >= 1e6) {
        result = sprintf("%.2fm", item/1e6);
    } else if (item >= 1e3) {
        result = sprintf("%.2fk", item/1e3);
    } else {
        result = sprintf("%s", item);
    }
    return result;
}

{
    Price       = $1
    MarketCap   = number_parse($2)
    VWAP        = $3
    Supply      = number_parse($4)
    Volume      = number_parse($5)
    Change      = $6

    $1=$2=$3=$4=$5=$6=""
    printf ( "%s,%.2f,%s,%.2f,%s,%s,%.2f%%\n", substr($0, 7), Price, MarketCap, VWAP, Supply, Volume, Change )

}
