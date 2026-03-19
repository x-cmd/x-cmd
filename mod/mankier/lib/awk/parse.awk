{
    print remove_label( $0 )
}

function remove_label( str ){
    gsub( /\\\//,     "/", str)
    gsub( "<p>",       "", str)
    gsub( "</p>",      "", str)
    gsub( "<strong>",  "", str)
    gsub( "</strong>", "", str)
    return str
}
