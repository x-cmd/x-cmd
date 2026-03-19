BEGIN{
    design_capacity = 0
}

function getval( name ){
    str = $0
    if ( match(str, name "[ ]*=[ ]*[0-9]+") ) {
        str = substr(str, RSTART, RLENGTH)
        match(str, /[0-9]+/)
        return substr(str, RSTART, RLENGTH)
    }
    return "NOT_FOUND"
}

{
    if ( (t=getval("\"DesignCapacity\"")) != "NOT_FOUND") {
        design_capacity = t
        next
    }

    # MaxCapacity
    if ( (t=getval("\"AppleRawMaxCapacity\"")) != "NOT_FOUND") {
        max_capacity = t
        next
    }
    if ( (t=getval("\"CurrentCapacity\"")) != "NOT_FOUND") {
        current_capacity = t
        next
    }
}

END{
    print "capacity:"
    print "  design: "   design_capacity
    print "  max: "      max_capacity
    print "  current: "  current_capacity

    if ( design_capacity > 0.00000001 ) {
        print "heath: "  max_capacity / design_capacity * 100 "%"
    } else {
        print "heath: 0%"
    }
}
