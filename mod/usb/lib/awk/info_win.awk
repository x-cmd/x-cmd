/Dependent=/ {
    gsub(/Dependent=/, "")
    gsub(/"/, "")
    printf "%s\n", $0
}