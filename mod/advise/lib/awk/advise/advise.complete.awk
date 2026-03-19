
# Completion candidate generation functions
# Generates completion suggestions based on current parsing state

# Resolves $ref references and parses groups (subcmd/option/flag)
# Returns true on success, false on failure (with error message in dev mode)
function advise_get_ref_and_group(obj, kp,        msg, subcmd_group, option_group, flag_group){
    if ((msg = comp_advise_get_ref(obj, kp)) != true) {
        if ( ___X_CMD_ADVISE_DEV_MOD == 1 ) advise_error( msg )
        else return false
    }
    # Parse and categorize items into groups
    comp_advise_parse_group(obj, kp, subcmd_group, option_group, flag_group)
    # Remove development tags (todo, inner) if not in dev mode
    comp_advise_remove_dev_tag_of_arr_group(obj, kp, subcmd_group)
    comp_advise_remove_dev_tag_of_arr_group(obj, kp, option_group)
    comp_advise_remove_dev_tag_of_arr_group(obj, kp, flag_group)
    return true
}

# Generates completion candidates for a given keypath
# Handles both static candidates (#cand) and dynamic items (subcmds, options)
#
# Parameters:
#   curval - Current value being typed (for filtering)
#   genv   - Global environment table
#   lenv   - Local environment table (tracks set options)
#   obj    - The advise object
#   kp     - Keypath to generate candidates for
function advise_get_candidate_code( curval, genv, lenv, obj, kp,        i, j, k, l, v, _option_id, _cand_key, _cand_l, _cand_kp, _is_cand_nospace, _desc, _arr_value, _arr_valuel, _keypath ) {
    l = aobj_len(obj, kp)

    for (i=1; i<=l; ++i) {
        _option_id = aobj_get(obj, kp SUBSEP i)

        # Handle static candidate definitions (#cand)
        if ( _option_id == "\"#cand\"" ) {
            _cand_key = kp SUBSEP _option_id
            _cand_l = aobj_len(obj, _cand_key)
            for (j=1; j<=_cand_l; ++j) {
                _cand_kp = _cand_key SUBSEP "\""j"\""
                v = aobj_get_cand_value( obj, _cand_kp)
                _cand_kp = _cand_kp SUBSEP v
                _is_cand_nospace = aobj_is_nospace(obj, _cand_kp)
                _desc = aobj_get_description(obj, _cand_kp)

                if (v ~ "^\"") v = juq(v)
                _arr_valuel = split( v, _arr_value, "|" )
                for (k=1; k<=_arr_valuel; ++k) {
                    v = _arr_value[k]

                    # Filter by current value (prefix matching)
                    if (curval != "") {
                        # Nospace match: curval starts with candidate
                        if ((_is_cand_nospace) && (curval ~ "^" v)) {
                            _keypath = CAND[ "KEYPATH" ]
                            CAND[ _keypath, "fixed" ] = true
                            CAND[ _keypath, "IS_NOSPACE" ] = true
                            CAND[ _keypath, "PREFIX" ] = v
                            # Continue completion with remainder
                            advise_complete___generic_value( substr( curval, length(v)+1 ), genv, lenv, obj, _cand_kp )
                            continue
                        }
                        # Regular prefix match
                        else if (index(v, curval) != 1) continue
                    }

                    # Store candidate with appropriate type
                    if (_is_cand_nospace) {
                        jdict_put( CAND, "NOSPACE", jqu(v), jqu(_desc) )
                        continue
                    }
                    jdict_put( CAND, "CODE", jqu(v), jqu(_desc) )
                }
            }
        }

        # Skip special metadata keys
        if ( _option_id ~ "^\"#" ) continue

        # Get description and handle aliases (e.g., "h|help")
        _desc = aobj_get_description(obj, kp SUBSEP _option_id)
        _arr_valuel = split( juq( _option_id ), _arr_value, "|" )
        for ( j=1; j<=_arr_valuel; ++j) {
            v = _arr_value[j]

            # Filter by prefix
            if ((curval != "") && (index(v, curval) != 1)) continue

            # Skip if already set and not multiple
            if ( ! aobj_is_multiple(obj, kp SUBSEP _option_id) && (lenv[ _option_id ] != "")) continue

            # Don't show options if curval is empty (unless subcommand)
            if (( curval == "" ) && ( v ~ "^-" ))
                if ( ! aobj_is_subcmd(obj, kp SUBSEP _option_id ) ) continue

            # Don't show long options if curval is just "-"
            if (( curval == "-" ) && ( v ~ "^--." )) continue

            # Store candidate
            if (aobj_is_nospace(obj, kp SUBSEP _option_id)) {
                jdict_put( CAND, "NOSPACE", jqu(v), jqu(_desc) )
                continue
            }
            jdict_put( CAND, "CODE", jqu(v), jqu(_desc) )
        }
    }
}

# Generic value completion handler
# Handles static candidates, exec commands, and regex matching
function advise_complete___generic_value( curval, genv, lenv, obj, kp,         _exec_val, _regex_id, _regexl, _regex_key, i ){
    # Get static candidates
    advise_get_candidate_code( curval, genv, lenv, obj, kp )

    # Handle dynamic execution candidates
    if ( (_exec_val = aobj_get_special_value(obj, kp, "exec")) != "" )                  jdict_put( CAND, "EXEC", _exec_val, "null" )
    if ( (_exec_val = aobj_get_special_value(obj, kp, "exec:stdout")) != "" )           jdict_put( CAND, "EXEC_STDOUT", _exec_val, "null" )
    if ( (_exec_val = aobj_get_special_value(obj, kp, "exec:stdout:nospace")) != "" )   jdict_put( CAND, "EXEC_STDOUT_NOSPACE", _exec_val, "null" )

    # Handle regex-based branching
    _regex_id = aobj_get_special_value_id( kp, "regex" )
    _regexl   = aobj_len(obj, _regex_id)
    for ( i=1; i<=_regexl; ++i ) {
        _regex_key = aobj_get(obj, _regex_id SUBSEP i)
        if (curval ~ "^"juq( _regex_key )"$" )
            return advise_complete___generic_value(curval, genv, lenv, obj, _regex_id SUBSEP _regex_key)
    }
}

# Completion for option values (--option <value>)
# Sets keypath to the option and delegates to generic handler
function advise_complete_option_value( curval, genv, lenv, obj, obj_prefix, option_id, arg_nth ){
    CAND[ "KEYPATH" ] = obj_prefix SUBSEP option_id
    return advise_complete___generic_value( curval, genv, lenv, obj, obj_prefix SUBSEP option_id SUBSEP "\"#" arg_nth "\"")
}

# Completion for positional arguments (rest args)
# Tries specific position first, then falls back to #n (any number)
function advise_complete_argument_value( curval, genv, lenv, obj, obj_prefix, nth,      _kp ){
    _kp = obj_prefix SUBSEP "\"#" nth "\""
    if ( advise_get_ref_and_group(obj, _kp) && (aobj_get(obj, _kp) != ""))
        return advise_complete___generic_value( curval, genv, lenv, obj, _kp )

    # Fall back to #n pattern (unlimited args)
    _kp = obj_prefix SUBSEP "\"#n\""
    if ( advise_get_ref_and_group(obj, _kp) && (aobj_get(obj, _kp) != ""))
        return advise_complete___generic_value( curval, genv, lenv, obj, _kp )
}

# Most complex completion case:
# Decides whether to show option names, argument values, or error
#
# Shows both options and arguments when:
# - Current value is empty
# - Current value starts with - (typing an option)
# - All required options are already set
#
# Otherwise, shows error about missing required options
function advise_complete_option_name_or_argument_value( curval, genv, lenv, obj, obj_prefix,          i, k, l, _required_options ){

    # Determine if we should show options or arguments
    if ( ( curval == "" ) || ( curval ~ /^-/ ) || (aobj_option_all_set( lenv, obj, obj_prefix ))) {
        advise_complete___generic_value( curval, genv, lenv, obj, obj_prefix )
        advise_complete_argument_value( curval, genv, lenv, obj, obj_prefix, 1)
        return true
    }

    # Check for missing required options
    l = aobj_len(obj, obj_prefix)
    for (i=1; i<=l; ++i) {
        k = aobj_get(obj, obj_prefix SUBSEP i)
        if (k ~ "^\"[^-]") continue           # Skip non-options
        if ( aobj_is_subcmd(obj, obj_prefix SUBSEP k ) ) continue
        if ( ! aobj_is_required(obj, obj_prefix SUBSEP k) ) continue
        if ( lenv[ k ] == "" ) _required_options = (_required_options == "") ? k : _required_options ", " k
    }
    if (_required_options != "")
        return advise_error("Required options [ " _required_options " ] should be set")

}
