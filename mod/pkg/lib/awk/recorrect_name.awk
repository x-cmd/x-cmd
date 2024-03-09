BEGIN{
        candidate_list = ""
        len = split(pkg_name, arr,"")
        str = gen_regex_by_wrong_name(arr, len)
}

{
    if($2 ~ "^"str){
        pkg_len = length($2)
        if (((pkg_len - 2) < len) && ((pkg_len + 4) > len) ) candidate_list = candidate_list $2"\n"
    }

}


END{
    printf("%s", candidate_list)
}


function gen_regex_by_wrong_name(arr, l,        i, regex){
    for(i=1; i<=l; ++i){
        if(i == 1)regex = arr[i]
        else regex = regex arr[i]"?""[*]?"
    }
    return regex
}
