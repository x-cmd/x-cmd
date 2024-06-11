
setenv  ___X_CMD_XBINEXP_FP     "$HOME/.x-cmd.root/local/data/xbinexp/csh/$$."`/bin/sh -c 'echo $PPID'`

mkdir -p "$___X_CMD_XBINEXP_FP"

# bash "$HOME/.x-cmd.root/bin/xbinexp" $argv

set ___X_CMD_XBINEXP_EXECFP = "$HOME/.x-cmd.root/bin/xbinexp"

set ___X_CMD_XBINEXP_INVOKE_STR = 'bash "$___X_CMD_XBINEXP_EXECFP"'
set ___X_CMD_CSH_RC_i = 1
while ( $___X_CMD_CSH_RC_i <= ${#argv} )
    # set ___X_CMD_XBINEXP_INVOKE_STR = "$___X_CMD_XBINEXP_INVOKE_STR \"\$argv[${___X_CMD_CSH_RC_i}]\""
    set ___X_CMD_XBINEXP_INVOKE_STR = "$___X_CMD_XBINEXP_INVOKE_STR"' "$argv['${___X_CMD_CSH_RC_i}']"'
    @ ___X_CMD_CSH_RC_i++
end
eval "$___X_CMD_XBINEXP_INVOKE_STR"


# Now do something
if ( -f "$___X_CMD_XBINEXP_FP/PWD" ) then
    set ___X_CMD_CSH_RC_data=""
    set ___X_CMD_CSH_RC_data=`cat "$___X_CMD_XBINEXP_FP/PWD"`
    if ( "$___X_CMD_CSH_RC_data" != "" ) cd "$___X_CMD_CSH_RC_data"
    rm -f "$___X_CMD_XBINEXP_FP/PWD"
endif


if ( -f "$___X_CMD_XBINEXP_FP/PATH" ) then
    set ___X_CMD_CSH_RC_data=""
    set ___X_CMD_CSH_RC_data=`cat "$___X_CMD_XBINEXP_FP/PATH"`
    if ( "$___X_CMD_CSH_RC_data" != "" ) setenv PATH "$___X_CMD_CSH_RC_data"
    rm -f "$___X_CMD_XBINEXP_FP/PATH"
endif


# consider : unset csubstnonl

set ___X_CMD_CSH_RC_allvar=`ls $___X_CMD_XBINEXP_FP | awk '{ print $1; gsub(/^[^_]*_/, "", $1); print $1;  }'`

if ( $#___X_CMD_CSH_RC_allvar > 0 ) then
    set ___X_CMD_XBINEXP_EVAL=""

    set ___X_CMD_CSH_RC_i = 1
    while ( $___X_CMD_CSH_RC_i < $#___X_CMD_CSH_RC_allvar )
        set ___X_CMD_CSH_RC_fp = $___X_CMD_CSH_RC_allvar[$___X_CMD_CSH_RC_i]
        @ ___X_CMD_CSH_RC_i++
        set name = $___X_CMD_CSH_RC_allvar[$___X_CMD_CSH_RC_i]
        @ ___X_CMD_CSH_RC_i++

        set ___X_CMD_CSH_RC_data="`cat "$___X_CMD_XBINEXP_FP/$___X_CMD_CSH_RC_fp"`"

        # TODO: Actually we should use setenv, but it fails. csh is still a riddle to me.
        if ( "$___X_CMD_CSH_RC_data" != "" ) eval "set $name = "'"$___X_CMD_CSH_RC_data"'
    end

    rm -f "$___X_CMD_XBINEXP_FP"/*

    if ( "$___X_CMD_XBINEXP_EVAL" != "" ) then
        set ___X_CMD_CSH_RC_eval = "$___X_CMD_XBINEXP_EVAL"
        set ___X_CMD_XBINEXP_EVAL = ""

        printf "\n%s\n" "===================" >"/dev/stderr"
        printf "[csh]\033[32m>>> \033[34;1m%s\033[0m\n" "$___X_CMD_CSH_RC_eval" >"/dev/stderr"
        printf "%s\n" "-------------------" >"/dev/stderr"
        eval "$___X_CMD_CSH_RC_eval"
        printf "\n%s\n" "===================" >"/dev/stderr"
    endif

endif

