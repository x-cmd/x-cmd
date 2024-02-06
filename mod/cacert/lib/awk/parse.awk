
function cacert_parse( _fs ){
    _fs = FS
    FS = "[ \t]+"

    while (getline) {
        if ($0 !~ "^###")   continue

        CA_NAME = $1
        while (getline) {
            if ($0 !~ /^[ \t]+$/) break
        }

        while ($0 ~ /^===/) {
            $1 = ""

            CA_INFO = $0
            gsub( "^[ \t]+", "", CA_INFO )

            # parse Certificate:
            while (getline) {
                if ($0 ~ "BEGIN CERTIFICATE")  break
                CA_STR = CA_STR "\n" $0
            }

            while (getline) {
                CA_CERT_BASE64 = CA_STR "\n" $0
                if ($0 ~ "END CERTIFICATE")  break
            }
        }
    }

    FS = _fs
}
