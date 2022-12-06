
function j2y_better_key( k ){
    if (k !~ /[:\t\n\v]/) {
        return juq(k)
    }
    return k
}
