BEGIN{
    result = ""
    AMPERSAND = "\n"
    EQUAL = ":"
    canonical_headers = ""
    signed_headers = ""
}

(($0 !~ "^[ ]+$") && ($0 != "")){
    i = index($0, ":")
    key = tolower(substr($0, 1, i-1))
    gsub(/^[ ]+|[ ]+$/, "", key)
    val = substr($0, i+1)
    gsub(/^[ ]+|[ ]+$/, "", val)

    canonical_headers = canonical_headers ( (canonical_headers == "") ? "" : AMPERSAND ) key EQUAL val
    signed_headers = signed_headers ( (signed_headers == "") ? "" : ";" ) key
}

END{
    print "canonical_headers=" shqu1( canonical_headers AMPERSAND)
    print "signed_headers=" shqu1( signed_headers )
}
