
function ystr___print_comment_mline( str, indent,      l, a ){
    l = split(str, a, "\n")
    ystr___print_comment_ml( l, a, indent )
}

function ystr___print_comment_ml( l, a, indent,      i ){
    if (l>=1) {
        printf("%s", a[1])
        printf("\n%s", indent)
    }
    for (i=2; i<=l-1; ++i) {        # last line always be empty line
        printf("%s", a[i])
        printf("\n%s", indent)
    }
}

# a:  bcd # cmt-bcd
# a:  # this is for key
# a:  # this is for value
      # this is for value
#     | 
#       actual value
function ystr___print_comment_val( o, kp, indent, v,    a, l ) {
    if (v == "") {
        if (o[ kp L L L ] != "") {
            l = split(o[kp L L L], a, "\n")
            ystr___print_comment_ml( l, a, indent )
        }
        return
    }

    if ( o[ kp L L L ] == "") {
        printf( "%s\n", v )
        return
    }

    l = split(o[ kp L L L ], a, "\n")
    if (l<=2) printf( "%s\n", v "  " a[1] )
    else {
        ystr___print_comment_ml( l, a, indent )
        printf( "%s\n", v )
    }
}

# Section: cmt
# root:     o[ L L kp ], o[ kp L L ]
function ystr___cmt_print_root_0( o, kp, indent ){
    if (o[ L L kp ] != "") {
        ystr___print_comment_mline(o[ L L kp ], indent)
        print
    }
}
function ystr___cmt_print_root_1( o, kp, indent ){
    if (o[ kp L L ] != ""){
        print
        ystr___print_comment_mline(o[ kp L L ], indent)
    }
}
# key:      o[ L kp ]
function ystr___cmt_print_key( o, kp, i ){      if (o[ L kp ] != "")        ystr___print_comment_mline(o[ L kp ], i );      }
# value:    o[ L L L kp ], o[ kp L L L ]
function ystr___cmt_print_val_0( o, kp, i ){    if (o[ L L L kp] != "")     ystr___print_comment_mline(o[ L L L kp ], i);   }
function ystr___cmt_print_val_1( o, kp, v ){    
    if (v != "") {
        if (o[ kp L L L ] != "")    printf("%s %s\n", v, o[ kp L L L ]);  
        else                        printf("%s\n", v);
        return
    }
    if (o[ kp L L L ] != "")    printf("%s\n", o[ kp L L L ]);  
}
# EndSection

function ystr_list( o, kp, indent,      i, l, k ){
    if ( 0 == (l = o[ kp L ]) ) {
        printf("%s\n", "[]")
        return
    }

    k = kp SUBSEP "\"" 1 "\""

    ystr___cmt_print_key( o, k )
    printf("- ")
    ystr_value( o, k, indent "  " )
    for (i=2; i<=l; ++i) {
        k = kp SUBSEP "\"" i "\""
        
        ystr___cmt_print_key( o, k )
        printf("%s- ", indent)
        ystr_value( o, k, indent "  " )
    }
}

function ystr_dict_print_val( o, k, indent ){
    if ( (o[k] ~ "^[\\[{]$") ) printf("\n%s", indent)
    else printf(" ")
    ystr_value( o, k, indent)
}

function ystr_dict___print_key( k ){
    return (k ~ "\"[A-Za-z0-9_-]+\"$") ? substr(k, 2, length(k)-2) : k
}

function ystr_dict( o, kp, indent,         i, l, k, _key ){
    if ( 0 == (l = o[ kp L ]) ) {
        printf("%s\n", "{}")
        return
    }

    k = kp SUBSEP ( _key = o[ kp, 1 ] )

    ystr___cmt_print_key( o, k )
    printf("%s:", ystr_dict___print_key(_key) )

    ystr_dict_print_val( o, k, indent "  " )
    for (i=2; i<=l; ++i) {
        k = kp SUBSEP ( _key = o[ kp, i ] )

        ystr___cmt_print_key( o, k )
        printf("%s%s:", indent, ystr_dict___print_key(_key) )
        ystr_dict_print_val( o, k, indent "  ")
    }
}

function ystr_value( o, kp, indent,     v, _v ){
    v = yml_obj_get_yval_or_val( o, kp )

    if (v == "{") {
        ystr___cmt_print_val_0( o, kp, indent )
        ystr_dict( o, kp, indent )
        ystr___cmt_print_val_1( o, kp )
        return
    }

    if (v == "[") {
        ystr___cmt_print_val_0( o, kp, indent )
        ystr_list( o, kp, indent )
        ystr___cmt_print_val_1( o, kp )
        return 
    }

    ystr___cmt_print_val_0( o, kp, indent )

    if (match(v, "^\"[A-Za-z0-9 _]+\"$")) v = substr(v, 2, length(v)-2)
    ystr___cmt_print_val_1( o, kp, v )
}

function ystr_root( o, kp, indent,      i, l ){
    if ( kp != "" ){
        ystr___cmt_print_root_0( o, kp, indent )
        ystr_value( o, kp, indent )
        ystr___cmt_print_root_1( o, kp, indent )
        return
    }

    l = o[ L ]
    if (l < 1) return
    kp = SUBSEP "\"" 1 "\""

    ystr___cmt_print_root_0( o, kp, indent )
    ystr_value( o, kp, indent )
    ystr___cmt_print_root_1( o, kp, indent )

    for (i=2; i<=l; ++i) {
        printf("---\n")
        kp = SUBSEP "\"" i "\""
        ystr___cmt_print_root_0( o, kp, indent )
        ystr_value( o, kp, indent )
        ystr___cmt_print_root_1( o, kp, indent )
    }
}

function ystr( o, kp, indent ){
    ystr_root( o, kp, indent )
}
