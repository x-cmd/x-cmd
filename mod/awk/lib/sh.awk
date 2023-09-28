
function shqu( s ){
    gsub(/\\/, "&\\", s)
    gsub(/\$/, "\\$", s)
    gsub("\"", "\\\"", s)
    return "\"" s "\""
}

function shuq( s ){
    gsub(/\\\$/, "$", s)
    gsub(/\\"/, "\"", s)
    gsub(/\\\\/, "\\", s)
    return substr(s, 2, length(s) - 2)
}

function shqu1( s ){
    gsub("'", "'\\''", s)
    return "'" s "'"
}

function shuq1( s ){
    gsub(/'\\''/, "'", s)
    return substr(s, 2, length(s) - 2)
}

function shexec( c,  _line, _ret, i ){
    i = 0
    while ((c | getline _line) > 0)   _ret = ("" == _ret) ? _line : (_ret "\n" _line)
    return _ret
}

function sh_code_eval( code ){
    code = shqu( code )
    return "eval " code
}

function sh_code_varset( name, value ){
    return name "=" shqu1(value)
}

# Section: case
function sh_case_begin( start ){
    _ = sprintf("case %s in", start)
}

function sh_case_item( pat, sentense ){
    _ = _ "\n" sprintf("%s) \n %s \n;;", pat, sentense)
}

function sh_case_end(){
    _ = _ "\n" "esac"
    return _
}
# EndSection

# Section: if
function sh_if_then( cond, then ){      _ =     sprintf( "if %s; then\n%s\n", cond, then ); }
function sh_if_else( elses ){           _ = _   sprintf( "else\n%s\n", elses );  }
function sh_if_elif( cond, els ){       _ = _   sprintf( "elif\n%s ; then\n %s \n", pat, els); }
function sh_if_end(){            return _ = _   "\nfi"; }

function sh_if_then_else( cond, then, els ) {
    return sprintf("if %s; then\n%s\nelse\n%s\nfi\n", cond, then, els)
}
# EndSection

# Section: for
function sh_for( var, iterlist, sentense ){
    return sprintf( "for %s in %s ; do\n%s\ndone", var, iterlist, sentense )
}
# EndSection

# Section: func, funcsub, sub, block
function sh_func( name, body ){         return sprintf("%s(){\n%s\n}", name, body);     }
function sh_funcsub( name, body ){      return sprintf("%s()(\n%s\n)", name, body);     }

function sh_sub( body ){                return sprintf("( %s )", body); }
function sh_block( body ){              return sprintf("{ %s }", body); }

function sh_valblock( body ){           return sprintf("\"$(%s)\"", body); }

function sh_pipe( a, b ){               return sprintf("%s | %s ", a, b);   }
# EndSection

# Section: call
function sh_call( c, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, t ){
    t = c
    if (arg1 == "") return t;   t = t " " arg1
    if (arg2 == "") return t;   t = t " " arg2
    if (arg3 == "") return t;   t = t " " arg3
    if (arg4 == "") return t;   t = t " " arg4
    if (arg5 == "") return t;   t = t " " arg5
    if (arg6 == "") return t;   t = t " " arg6
    if (arg7 == "") return t;   t = t " " arg7
    if (arg8 == "") return t;   t = t " " arg8
    if (arg9 == "") return t;   t = t " " arg9
    if (arg10 == "") return t;   t = t " " arg10
    return t
}

function sh_eval( arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10 ) {
    return sh_call("eval", arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10 )
}

function sh_exec( arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10 ) {
    return sh_call("exec", arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10 )
}

function sh_x( arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10) {
    return sh_call("x", arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10 )
}

function sh_hascmd( c ){
    return sprintf("command -v %s 2>/dev/null", c)
}
# EndSection

# Section: varset

function sh_var_local( var ){
    return "local " var " >/dev/null 2>&1; "
}

function sh_varset( var, token, is_local,       _local ){
    if (is_local == true) _local = sh_var_local( var )
    return _local sprintf("%s=%s", var, token)
}

function sh_varset_val( var, val, is_local,       _local ){
    if (is_local == true) _local = sh_var_local( var )
    return _local sh_varset(var, shqu1(val))
}

function sh_varset_var( var, var1, is_local,       _local ){
    if (is_local == true) _local = sh_var_local( var )
    return _local sh_varset(var, "\"$" var1 "\"")
}

# EndSection
