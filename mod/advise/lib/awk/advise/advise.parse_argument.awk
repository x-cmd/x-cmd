
# Section: Argument Preparation
# Prepares the raw argument string into a structured array for parsing

# Prepares the argument string into an array
# - Converts newlines to \001 temporarily to preserve them during split
# - Handles escaped spaces (\ )
# - Splits by \002 (the separator used in x-cmd)
# - Restores newlines from \001
#
# Parameters:
#   argstr - Raw argument string with \002 separators
#   arr    - Output array (1-indexed), arr[L] stores the length
function prepare_argarr( argstr, arr,      l, i, _arg ){
    # Replace actual newlines with \001 temporarily
    gsub("\n", "\001", argstr)
    # Unescape escaped spaces
    gsub("\\\\ ", " ", argstr)
    # Split by \002 separator
    l = split(argstr, arr, "\002")
    arr[L] = l
    for (i=1; i<=l; ++i) {
        _arg = arr[i]
        # Restore newlines from \001
        gsub("\001", "\n", _arg)
        arr[i] = _arg
    }
}

# EndSection

# Section: Parse Arguments into Environment Table
#
# This section handles the core argument parsing logic:
# 1. Complete Rest Argument - When filling positional arguments
# 2. Complete Option Name Or Rest Argument - When at command/subcommand level
# 3. Complete Option Argument - When providing values for options

# Sets a flag value (true/1) in both global and local environment tables
function env_table_set_true( key, keypath, genv_table, lenv_table ){
    env_table_set( key, keypath, 1, genv_table, lenv_table )
}

# Sets a value in both environment tables
# genv_table: Global env with full keypath (e.g., \037"1"\037"--option")
# lenv_table: Local env with just the option name (e.g., "--option")
function env_table_set( key, keypath, value, genv_table, lenv_table ){
    genv_table[ keypath ] = value
    lenv_table[ key ] = value
}

# Handles option argument parsing
# Supports both flags (no arguments) and options with arguments
#
# Returns:
#   - arg_idx if successful (index of next argument to process)
#   - 0 if option not found
function parse_args_to_env___option( obj, obj_prefix, args, argl, optarg_id, arg_idx, genv_table, lenv_table,
    _optargc, k ){
    if (optarg_id == "") return false

    # Get the number of arguments this option expects
    _optargc = aobj_get_optargc( obj, obj_prefix, optarg_id )

    if (_optargc == 0) {
        # This is a flag (no arguments) - just mark it as set
        env_table_set_true( optarg_id, obj_prefix SUBSEP optarg_id, genv_table, lenv_table )
        return arg_idx
    }

    # Process each expected argument for this option
    for (k=1; k<=_optargc; ++k)  {
        if ( arg_idx >= argl ) {
            # Not enough arguments - trigger completion for this option value
            advise_complete_option_value( args[ arg_idx ], genv_table, lenv_table, obj, obj_prefix, optarg_id, k )
            return ++arg_idx  # Return beyond argl to signal completion needed
        }
        # Store the argument value in environment tables
        env_table_set( optarg_id, obj_prefix SUBSEP optarg_id SUBSEP k, args[ arg_idx++ ], genv_table, lenv_table )
        # Handle nospace arguments (e.g., -I/path) that may have changed argl
        if ( parse_trim_args( obj, obj_prefix, args, arg_idx ) ) argl = args[ L ]
    }
    return arg_idx
}

# Handles "nospace" arguments like -I/path or --option=value
# These are arguments that don't require a space between option and value
#
# Parameters:
#   obj    - The advise object
#   kp     - Current keypath prefix
#   args   - Arguments array
#   id     - Current argument index
#
# Returns:
#   true if nospace argument was found and split
#   false otherwise
function parse_trim_args( obj, kp, args, id,          v, k, i, j, l, n, nl, _, num, argl, tf ){
    if ( (tf = args[ id, "fixed" ]) != "" ) return tf
    v = args[ id ]
    l = aobj_len(obj, kp)

    # Check each nospace option to see if current arg matches its prefix
    for (i=1; i<=l; ++i){
        k = aobj_get(obj, kp SUBSEP i)
        if ( ! aobj_is_nospace(obj, kp SUBSEP k) ) continue

        CAND[ kp, k, "IS_NOSPACE" ] = true
        nl = split(juq(k), _, "|")
        for (n=1; n<=nl; ++n){
            # Check if argument starts with this option prefix
            if (match(v, "^" _[n])) {
                CAND[ kp, k, "PREFIX" ] = _[n]
                CAND[ "NOSPACE_NUM" ] ++

                # Split the nospace arg: -I/path -> -I, /path
                args[ id ] = substr(v, 1, RLENGTH)
                argl = args[ L ] = args[ L ] + 1
                num = id + 1
                # Shift remaining args to make room
                for (j=argl; j>num; --j) args[ j ] = args[ j - 1 ]
                args[ num ] = substr(v, RLENGTH+1)
                return ( args[ id, "fixed" ] = true )
            }
        }
    }
    return ( args[ id, "fixed" ] = false )
}

# Main argument parsing function
# Parses user arguments and builds environment tables
# Triggers completion when reaching the argument being completed
#
# Parameters:
#   args        - Prepared argument array
#   obj         - Parsed advise object from jso file
#   obj_prefix  - Current keypath in obj (starts with SUBSEP "1")
#
# The function processes arguments in order:
# 1. Resolves $ref references
# 2. Handles subcommand navigation
# 3. Parses options and their values
# 4. Handles positional arguments
# 5. Triggers appropriate completion
function parse_args_to_env( args, obj, obj_prefix,              genv_table, lenv_table, i, j, k, _arg_id, _subcmdid, _optarg_id, _arg_arr, _arg_arrl, _optargc, _rest_argc, rest_argc_max, argl, arg, rest_arg ){

    # Resolve $ref references and parse groups (subcmd/option/flag)
    if (! advise_get_ref_and_group(obj, obj_prefix)) return false

    # Handle nospace for first argument
    parse_trim_args(obj, obj_prefix, args, (i = 1))
    argl = args[ L ]
    CAND[ "KEYPATH" ] = obj_prefix

    # Main parsing loop - process each argument
    while ( i<argl ) {
        arg = args[ i ]
        i++

        # Find the ID for this argument name (handles aliases like "h|help")
        _arg_id = aobj_get_id_by_name( obj, obj_prefix, arg )

        # Check if this is a subcommand
        _subcmdid = aobj_get_subcmdid_by_id( obj, obj_prefix, _arg_id )
        if (_subcmdid != "") {
            # Validate that all required options are set before entering subcommand
            if ( ! aobj_option_all_set( lenv_table, obj, obj_prefix ) ) {
                return advise_error("All required options should be set")
            }
            # Enter subcommand context
            obj_prefix = obj_prefix SUBSEP _subcmdid
            CAND[ "KEYPATH" ] = obj_prefix
            if (! advise_get_ref_and_group(obj, obj_prefix)) return false
            if ( parse_trim_args(obj, obj_prefix, args, i) ) argl = args[ L ]
            delete lenv_table  # Reset local env for new context
            continue
        }

        # Handle long options (--option)
        if (aobj_is_option( obj, obj_prefix SUBSEP _arg_id ) || (arg ~ /^--/)) {
            j = parse_args_to_env___option( obj, obj_prefix, args, argl, _arg_id, i, genv_table, lenv_table )
            argl = args[ L ]
            if (j > argl) return true       # Completion triggered
            else if (j != 0) { i = j; continue; }
            else { i = i - 1; break; }      # Unknown, leave for completion
        }
        # Handle short options (-o) and combined short options (-abc)
        else if (arg ~ /^-/) {
            # First try as a complete option (e.g., -file)
            j = parse_args_to_env___option( obj, obj_prefix, args, argl, _arg_id, i, genv_table, lenv_table )
            argl = args[ L ]
            if (j > argl) return true
            else if (j != 0) { i = j; continue; }

            # Try as combined short options (e.g., -abc = -a -b -c)
            _arg_arrl = split(arg, _arg_arr, "")
            for (j=2; j<=_arg_arrl; ++j) {
                _optarg_id = aobj_get_id_by_name( obj, obj_prefix, "-" _arg_arr[j] )
                if ( _optarg_id == "" ) break
                _optargc = aobj_get_optargc( obj, obj_prefix, _optarg_id )

                if (_optargc == 0) {
                    # Flag - just mark as set
                    env_table_set_true( _optarg_id, obj_prefix SUBSEP _optarg_id, genv_table, lenv_table )
                    continue
                }

                # If not at last char, error (needs argument)
                if (j<_arg_arrl) return advise_error("Fail at parsing: " arg ". Accept at least one argument: -" _arg_arr[j] )

                # Process arguments for this option
                for (k=1; k<=_optargc; ++k)  {
                    if ( i>=argl ) {
                        # Trigger completion for this option's value
                        advise_complete_option_value( args[i], genv_table, lenv_table, obj, obj_prefix, _optarg_id, k )
                        return true
                    }
                    env_table_set( _optarg_id, obj_prefix SUBSEP _optarg_id SUBSEP k, args[ i++ ], genv_table, lenv_table )
                }
            }
            continue
        }
        # Not an option, treat as positional argument
        i = i - 1
        break
    }

    # Calculate offset for completion (accounting for nospace splits)
    CAND[ "OFFSET" ] = i - CAND[ "NOSPACE_NUM" ]
    CAND[ "NOSPACE_NUM" ] = 0

    # Collect remaining positional arguments (currently unused but kept for future validation)
    # for (j=1; int(i+j-1) < argl; ++j) rest_arg[ j ] = args[ i+j-1 ]
    # _rest_argc = j - 1
    _rest_argc = (i >= argl) ? 0 : (argl - i - 1)

    # Determine what to complete
    arg = args[ argl ]

    # No positional args yet - complete option names or first positional arg
    if (_rest_argc == 0)
        return advise_complete_option_name_or_argument_value( arg, genv_table, lenv_table, obj, obj_prefix )

    # Already have positional args - complete the next one
    rest_argc_max = aobj_get_maximum_rest_argc( obj, obj_prefix )
    if (_rest_argc >= rest_argc_max)  return  # Max args reached

    return advise_complete_argument_value( arg, genv_table, lenv_table, obj, obj_prefix, _rest_argc+1 )

}
# EndSection
