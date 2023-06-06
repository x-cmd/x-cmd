
BEGIN {
    SEMVER_RE_ALNUM = "[A-Za-z][A-Za-z0-9]+|[0-9]+"
    SEMVER_RE_NUM = "([0-9]|[1-9][0-9]+)"
    SEMVER_RE_DIG = "([0-9]+)"
    SEMVER_RE_CORE = SEMVER_RE_NUM "\\." SEMVER_RE_NUM "\\." SEMVER_RE_NUM

    SEMVER_RE_PREID = SEMVER_RE_ALNUM # "|" SEMVER_RE_NUM
    SEMVER_RE_PREDID = SEMVER_RE_PREDID "(\\." SEMVER_RE_PREID ")*"


    SEMVER_RE_BUILDID = SEMVER_RE_ALNUM "|" SEMVER_RE_DIG
    SEMVER_RE_BUILDDID = SEMVER_RE_BUILDID "(\\." SEMVER_RE_BUILDID ")*"

    SEMVER_RE = SEMVER_RE_CORE "(\\-" SEMVER_RE_PREDID ")?" "(\\+" SEMVER_RE_BUILDDID ")?"

    # SEMVER_RE_PRE = SEMVER_RE_CORE "\\-" SEMVER_RE_PREDID
    # SEMVER_RE_BUILD = SEMVER_RE_CORE "\\+" SEMVER_RE_BUILDDID
    # SEMVER_RE_PREBUILD = SEMVER_RE_CORE "\\-" SEMVER_RE_PREDID "\\+" SEMVER_RE_BUILDDID
    # SEMVER_RE = SEMVER_RE_CORE "|" SEMVER_RE_PRE "|" SEMVER_RE_BUILD "|" SEMVER_RE_PREBUILD
}

function semver_validate( s ){
    return match(s, SEMVER_RE)
}

function semver_major( s,   a, l ){     l = split(s, a, "."); return a[1];  }
function semver_minor( s,   a, l ){     l = split(s, a, "."); return a[2];  }
function semver_patch( s,   a, l ){     l = split(s, a, "."); return int(a[3]);  }

function semver_pre(){
    l = split(s, a, ".")
    if (a[3] ~ /^.+\-/) {

    }
}

function semver_build(){
    l = split(s, a, ".")
    if (a[3] ~ /^[0-9]+\+/) {

    }
}

# TODO: Let's see in the future.
function semver_cmp( a, b,      arr ){
    arr_push(arr, a)
    arr_push(arr, b)
    semver_sort_init(arr, 2)
    return semver_sort_qsort_cmp(arr, 1, 2)
}

# Section: sort
# Using quicksort ... 1000 * (log 2 1000) = 10000. It is OK ~
function semver_sort( a, l ) {
    if (l == "") l = a[ L ]
    semver_sort_init( a, l )
    semver_sort_qsort( a, 1, l )
}

function semver_sort_init( a, l,    i, e, _a,   t, u  ) {
    for (i=1; i<=l; ++i) {
        split(a[i], _a, ".")
        a[ i "\001" ] = _a[1]
        a[ i "\002" ] = _a[2]
        t = substr(a[i], length(_a[1]) + length(_a[2]) + 3)
        a[ i "\003" ] = u = int(t)
        a[ i "\004" ] = substr(t, length(u)+2)
    }
}

function semver_sort_qsort(arr, start, end,  i,j,k){
    if (start>=end) return
    i = start-1
    j = end+1

    k = int( (i + j) / 2 )

    while (i<j) {
        while (semver_sort_qsort_cmp( arr, ++i, k )) { }
        while (semver_sort_qsort_cmp( arr, k, --j )) { }
        if (i < j) semver_sort_qsort_swap( arr, i, j )
    }

    if (start < j ) semver_sort_qsort(arr, start, j)
    if (j+1 < end)  semver_sort_qsort(arr, j+1, end)
}

function semver_sort_qsort_cmp( a, i, j ){
    if (a[ i "\001" ] != a[ j "\001" ]) return a[ i "\001" ] < a[ j "\001" ]
    if (a[ i "\002" ] != a[ j "\002" ]) return a[ i "\002" ] < a[ j "\002" ]
    if (a[ i "\003" ] != a[ j "\003" ]) return a[ i "\003" ] < a[ j "\003" ]
    return a[ i "\004" ] < a[ j "\004" ]
}

function semver_sort_qsort_swap( a, i, j ){
    semver_sort_qsort_swap0( a, i, j )
    semver_sort_qsort_swap0( a, i "\001", j "\001" )
    semver_sort_qsort_swap0( a, i "\002", j "\002" )
    semver_sort_qsort_swap0( a, i "\003", j "\003" )
    semver_sort_qsort_swap0( a, i "\004", j "\004" )
}

function semver_sort_qsort_swap0( a, i, j,   t ){
    t = a[ i ]; a[ i ] = a[ j ]; a[ j ] = t
}
# EndSection

# Section: radix sort ... Unimplemeted. Left for the future performance boost.
# Radix sort ...
# Split the version
# - > "" > + > "."

# a.b.c-abc < a.b.c < a.b.c+1.2 < a.b.c+123
# a.b.c[1]abc < a.b.c[2] < a.b.c[3]1.2 < a.b.c[3]123
function semver_tr( a ){
    gsub("-", "\001", a)
    gsub("[+]", "\003", a)
    gsub(/^([0-9]+\.){2}[0-9]+/, "&\002", a)    # Not - +
}

# 1000 * 3
# 1000 join + 1 big split + 3 big gsub
function semver_trarr( a,  l, i ){
    for (i=1; i<=l; ++i) a[i] = semver_tr(a[i])
    return l
}
# EndSection
