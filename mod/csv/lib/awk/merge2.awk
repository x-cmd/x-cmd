BEGIN{

    csv1            = ENVIRON[ "csv1" ]
    csv2            = ENVIRON[ "csv2" ]

    arr_cut( arr1, csv1, "\n" )
    arr_cut( arr2, csv2, "\n" )

    csv_parse( arr1, csv_obj1 )
    csv_parse( arr2, csv_obj2 )

    merge_csv(csv_obj1, csv_obj2)
    print csv_dump(csv_obj1)

}


function merge_csv(csv1, csv2,                row1, i, j, col1, col2 ){
    col1 = csv_obj1[ L L ]
    col2 = csv_obj2[ L L ]

    row1 = csv_obj1[L]
    for(i=1; i<=row1; ++i){
        for(j=1; j<=col2; ++j){
            csv_obj1[ S i S (col1 + j) ] = csv_obj2[ S i S j ]
        }
    }
    csv_obj1[ L L ] = col1 + col2
}




