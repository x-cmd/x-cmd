{
    if (match($0, "^[^/]+://")) {
        protocol = substr( $0, 1, RLENGTH )
        body = substr( $0, RLENGTH + 1 )
    } else {
        protocol = ""
        body = $0
    }
    print protocol urldecode( body )
}
