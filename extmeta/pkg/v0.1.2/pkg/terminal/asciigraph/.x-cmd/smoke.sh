
# shellcheck shell=dash

if ! (seq 1 72 | asciigraph -h 10 -c "plot data from stdin" 2>&1);then
    pkg:error "fail to get help"
    return 1
fi
