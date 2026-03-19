# {  print }
($0~"^///"){
    while (getline) {
        md5sum = $1
        $1 = ""
        gsub("^[ ]+", "", $0)
        if (index(q, $0) > 0) break
    }

    print md5sum
    print $0
}