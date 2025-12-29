{
    yml_text = yml_text $0
    yml_text = yml_text "\n" #fix : some versions of mawk
}

END{
    Q2_1 = SUBSEP "\"1\""
    yml_parse( yml_text, o )

    PLATFORM = ENVIRON[ "PLATFORM" ]
    COMPILE_SHELLNAME = ENVIRON[ "COMPILE_SHELLNAME" ]

    shortcut_parse_toarr( o, ARR, PLATFORM )
    shortcut_parse_toshellcode( ARR, COMPILE_SHELLNAME )
}

function shortcut_parse_toshellcode( arr, shellname,          i, j, l, word, cmd, advfp, posix_advstr, elvish_advstr, fish_advarr, tcsh_advarr, xonsh_cmdarr, xonsh_cmdarrl, xonsh_cmdword, xonsh_cmdstr ){
    l = arr[ L ]
    for (i=1; i<=l; ++i){
        word = arr[ i, "\"word\"" ]
        if (arr[ word, "\"status\"" ] == "disable") continue
        cmd = arr[ word, "\"cmd\"" ]
        if (( shellname == "bash" ) || ( shellname == "zsh" )) {
            advfp = arr[ word, "\"advisefp\"" ]
            if ( word ~ "^a:" ) word = "@" substr( word, 3 )
            print "function " word "() { "cmd " \"$@\"; }"

            if (advfp != "") {
                advfp = jqu(advfp)
                posix_advstr = posix_advstr "\n\t[ ! -f " advfp " ] || ___x_cmd advise init " word " " advfp " ;"
            }
        }
        else if (shellname == "posixshell") {
            if ( word ~ "^a:" ) word = "@" substr( word, 3 )
            print "alias " word "=" shqu1(cmd)
        }
        else if (shellname == "fish") {
            if (match(cmd, "^(___x_cmd|x) cd($| )")) cmd = "___x_cmd_cd" substr(cmd, RLENGTH+1)
            if ( word ~ "^a:" ) word = "@" substr( word, 3 )
            print "function " word "\n    " cmd " $argv\nend"
            fish_advarr[ ++fish_advarr[L] ] = word
        }
        else if (shellname == "elvish") {
            if ( match(cmd, "^(___x_cmd|x) ") ) {
                cmd = substr(cmd, RLENGTH+1)
                if (match(cmd, "^cd($| )"))   cmd = "use x; x:___x_cmd_cd " substr(cmd, RLENGTH+1)
                else                    cmd = "use x; x:x " cmd
            }

            elvish_advstr = elvish_advstr word " "
            if ( word ~ "^a:" ) {
                word = substr( word, 3 )
                if ( word == "" ) continue
                print "fn " word " { |@a| " cmd " $@a ; }"
            } else {
                print "fn " word " { |@a| " cmd " $@a ; }\nedit:add-var " word "~ $" word "~"
            }
        }
        else if (shellname == "nu") {
            print "export alias " word " = " cmd
        }
        else if (shellname == "xonsh") {
            if ( word ~ "^a:" ) word = "@" substr( word, 3 )
            xonsh_cmdarrl = split(cmd, xonsh_cmdarr, " ")
            xonsh_cmdstr = ""
            for (j=1; j<=xonsh_cmdarrl; ++j){
                xonsh_cmdword = xonsh_cmdarr[ j ]
                if (xonsh_cmdword !~ "^(\"|')") xonsh_cmdword = shqu1(xonsh_cmdword)
                xonsh_cmdstr = ( xonsh_cmdstr != "" ) ? xonsh_cmdstr ", " xonsh_cmdword : xonsh_cmdword
            }
            print "aliases["shqu1(word)"] = [ "xonsh_cmdstr " ]"
        }
        else if (shellname == "tcsh") {
            word = arr[ i, "\"word\"" ]
            cmd = arr[ word, "\"cmd\"" ]
            if ( word ~ "^a:" ) {
                word = substr( word, 3 )
                if ( word == "" ) continue
                word = "@" word
            }
            print "alias " word "\t" shqu1(cmd)
            tcsh_advarr[ ++tcsh_advarr[L] ] = word
        }
        else if (shellname == "pwsh") {
            word = arr[ i, "\"word\"" ]
            cmd = arr[ word, "\"cmd\"" ]
            if (match(cmd, "^(___x_cmd|x) cd($| )")) cmd = "___x_cmd_cd" substr(cmd, RLENGTH+1)
            gsub( ":", "`&", word )
            print "function " word "(){\n\t" cmd " @args\n}"
        }
    }

    if ( posix_advstr != "" ) {
        posix_advstr = "\n\txrc:mod:lib advise env" posix_advstr
        posix_advstr = "if ___x_cmd_is_suitable_advise_repl 2>/dev/null 1>&2; then" posix_advstr "\nfi"
        print posix_advstr
    } else if ( elvish_advstr != "" ) {
        print "if ( eq $E:___X_CMD_ADVISE_ACTIVATION_ON_NON_POSIX_SHELL '1' ) {"
        print "\tput " elvish_advstr "| {"
        print "\t\teach {|c|"
        print "\t\t\tset edit:completion:arg-completer[$c] = {|@a|"
        print "\t\t\t\teval ( x advise complete elv normal $@a | slurp ) 2>/dev/null"
        print "\t\t\t}"
        print "\t\t}"
        print "\t}"
        print "}"
    } else if ( (l=fish_advarr[ L ]) > 0 ) {
        print "if [ \"$___X_CMD_ADVISE_ACTIVATION_ON_NON_POSIX_SHELL\" = '1' ]"
        for (i=1; i<=l; ++i){
            print "\tcomplete -c '" fish_advarr[i] "' -f -a '(___x_cmd_advise_run_fish normal " fish_advarr[i] ")' ;"
        }
        print "end"
    } else if ( (l=tcsh_advarr[ L ]) > 0 ) {
        print "if ( $?___X_CMD_ADVISE_ACTIVATION_ON_NON_POSIX_SHELL ) then"
        print "\tif ( \"$___X_CMD_ADVISE_ACTIVATION_ON_NON_POSIX_SHELL\" == 1 ) then"
        for (i=1; i<=l; ++i){
            print "\t\tcomplete \"" tcsh_advarr[i] "\" 'p@*@`echo \"$COMMAND_LINE'\"''\"'\" | xargs bash \"$HOME/.x-cmd.root/bin/___x_cmdexe\" advise complete tcsh normal `@@' ;"
        }
        print "\tendif"
        print "endif"
    }
}
