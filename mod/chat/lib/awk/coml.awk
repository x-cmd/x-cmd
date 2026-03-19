
function coml_handle( filelist, question,  ){

}

function coml_parse( content, o, kp,    content_arr, l, line  ){
    l = split( content, content_arr, "\n" )
    for (i=1; i<=l; ++i) {
        line = content_arr[ i ]
        if (line == "") continue

        if (line ~ "^<((file)|(plan)|(history)|(question))") {

        }
    }
}

# this is an array ...
function coml_outline( o, kp ){

}

function coml_body( key,     o, kp ) {
    return o[ kp, key ]
}

function coml_body_recap( o, kp ) {      return coml_body( o, kp, "memo" );      }
function coml_body_history( o, kp ) {   return coml_body( o, kp, "history" );   }
function coml_body_file( o, kp ) {      return coml_body( o, kp, "file" );      }
function coml_body_tool( o, kp ) {      return coml_body( o, kp, "tool" );      }

function coml_attr( key, attr,    o, kp ) {
    return o[ kp, key, attr ]
}

function coml_attr_history( o, kp ) {   return coml_attr( o, kp, "history" );   }
function coml_attr_file( o, kp ) {      return coml_attr( o, kp, "file" );      }
function coml_attr_tool( o, kp ) {      return coml_attr( o, kp, "tool" );      }
