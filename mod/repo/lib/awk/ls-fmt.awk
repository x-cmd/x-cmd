BEGIN {
    print "provider" sep "owner" sep "name" sep "filepath"
}

length($0) > 0 {
    sub(/\/\.git\/config$/, "")
    sub(/\.git$/, "")

    n = split($0, p, "/")
    provider = p[1]
    name     = p[n]

    if (n >= 3) {
        org = p[2]
        for (i = 3; i < n; i++) {
            org = org "/" p[i]
        }
    } else {
        org = ""
    }

    print provider sep org sep name sep $0
}