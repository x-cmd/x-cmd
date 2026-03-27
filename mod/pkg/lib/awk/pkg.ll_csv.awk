# shellcheck shell=awk disable=SC2016
# pkg ll --csv awk script
# Parse info.tt.json and output CSV format

{
    kp = SUBSEP "\"1\"" SUBSEP $0
    jiparse2leaf_fromfile(O, kp, $0)
    print_pkg_csv(O, kp)
    delete O
}

function print_pkg_csv(O, kp,    bin, homepage, license, desc_en, desc_cn, version, size, l, i, key, size_kp){

    # Extract fields
    bin = juq(O[kp S "\"bin\""])
    # Skip if bin is empty (no valid package name)
    if (bin == "") return
    homepage = juq(O[kp S "\"homepage\""])
    license = juq(O[kp S "\"license\""])
    desc_en = juq(O[kp S "\"desc\"" S "\"en\""])
    desc_cn = juq(O[kp S "\"desc\"" S "\"cn\""])

    # Remove newlines from descriptions to ensure single-line CSV output
    gsub(/[\r\n]+/, " ", desc_en)
    gsub(/[\r\n]+/, " ", desc_cn)

    # Escape commas and quotes for CSV
    bin = csv_quote_ifmust(bin)
    homepage = csv_quote_ifmust(homepage)
    license = csv_quote_ifmust(license)
    desc_en = csv_quote_ifmust(desc_en)
    desc_cn = csv_quote_ifmust(desc_cn)

    # Get version and size - find the latest version (last in list)
    # jiparse2leaf preserves JSON field order, so last version is the latest
    version = ""
    size = ""
    l = O[kp L]

    # First pass: collect all version keys to find the latest
    for (i = 1; i <= l; i++) {
        key = juq(O[kp S i])
        # Skip metadata fields
        if (key == "homepage" || key == "desc" || key == "license" || key == "bin") {
            continue
        }
        # Check if it looks like a version (starts with v or number)
        if (key ~ /^v?[0-9]/) {
            # Always update version to the current one (last one wins = latest)
            version = key
        }
    }

    # Second pass: get size for the latest version only
    if (version != "") {
        size_kp = kp S "\""version"\"" S "\"info\"" S "\"size\""
        # Check if size exists and is not null (check L property for object existence)
        if (O[size_kp L] > 0) {
            size = get_size_value(O, size_kp)
        }
    }

    version = csv_quote_ifmust(version)
    size = csv_quote_ifmust(size)

    # Output CSV line
    printf "%s,%s,%s,%s,%s,%s,%s\n", bin, desc_en, desc_cn, homepage, size, license, version
}

function get_size_value(O, size_kp,    size_l, j, arch_key, first_size) {
    size_l = O[size_kp L]
    first_size = ""
    for (j = 1; j <= size_l; j++) {
        arch_key = juq(O[size_kp S j])
        if (j == 1) {
            first_size = juq(O[size_kp S "\""arch_key"\""])
        }
        # Prefer linux/x64 if available
        if (arch_key == "linux/x64") {
            return juq(O[size_kp S "\""arch_key"\""])
        }
    }
    return first_size
}
