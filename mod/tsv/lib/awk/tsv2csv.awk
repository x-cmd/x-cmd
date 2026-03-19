{
    _res = tsv_tocsv_item($1)
    for (i=2; i<=NF; ++i) {
        _res = _res "," tsv_tocsv_item($i)
    }
    print _res
}

function tsv_tocsv_item(s){
    gsub("\\\\t", "\t", s)
    gsub("\\\\r", "\r", s)
    gsub("\\\\n", "\n", s)
    s = csv_quote_ifmust(s)
    return s
}
