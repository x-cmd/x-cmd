{
    if ($0 ~ "^###[ ]docker-compose") {
        while (getline) {
            if ($0 ~ /^```/) {
                break
            }
        }

        while (getline && $0 !~ /^```/) {
            # replace /path/to/ to VOLUME_ROOT
            gsub("/path/to", ENVIRON["VOLUME_ROOT"], $0)
            print
        }

        exit(0)
    }
}
