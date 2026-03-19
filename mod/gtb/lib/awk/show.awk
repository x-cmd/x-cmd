
$0~/\*\*\*[ ]?START[ ]OF[ ].+PROJECT[ ]GUTENBERG[ ]EBOOK/{
    state = 1
    while ($0 !~ /\*\*\*[\t \r\n]?*$/) { getline }
    getline
    while ($0 ~ /^[\t \r\n]*$/) {  getline }
    while ($0 ~ /Produced[ ]by[ ]/) { getline }
    while ($0 ~ /^[\t \r\n]*$/) {  getline }
}

$0~/\*\*\*[ ]?END[ ]OF[ ].+PROJECT[ ]GUTENBERG[ ]EBOOK/{
    exit(0)
}

{
    if (state == 1) {
        c += 1
        print
    } else {
        data[++b] = $0
    }
}

END{
    if (c == 0) {
        for (i=1; i<=b; ++i) print data[i]
    }
}
