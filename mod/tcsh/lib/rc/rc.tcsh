# add path to .x-cmd.root/bin and .x-cmd.root/global/data/bin/l/j/h

# TODO: improve this ...
if ( "$PATH" !~ *$HOME/.x-cmd.root/bin* ) then
    setenv PATH $HOME/.x-cmd.root/bin:$HOME/.x-cmd.root/global/data/bin/l/j/h/bin:$PATH
endif

setenv  ___X_CMD_CD_RELM_0      "$PWD"

# alias x             bash "$HOME/.x-cmd.root/bin/xbin"
# alias ___x_cmd      bash "$HOME/.x-cmd.root/bin/xbin"

alias x             ___x_cmd
alias ___x_cmd      source "$HOME/.x-cmd.root/bin/rc.x.tcsh"


# TODO: in the future, adding the advise

setenv CSH_VERSION "${version}"

setenv ___X_CMD_IS_INTERACTIVE_FORCE 1
setenv ___X_CMD_THEME_RELOAD_DISABLE 1

# "$HOME/.x-cmd.root/bin/xbin" prepare alias
if ($?status && $status == 0) then
    # eval "`___x_cmd chat --aliasinit --cshcode`"
    alias @o         'x chat --sendalias o'
    alias @gpt       'x chat --sendalias gpt'
    alias @gpt3      'x chat --sendalias gpt3'
    alias @gpt4      'x chat --sendalias gpt4'
    alias @kimi      'x chat --sendalias kimi'
    alias @gemini    'x chat --sendalias gemini'
    alias @mistral   'x chat --sendalias mistral'
    # chat, writer, w

    alias xw 'x ws'

    # TODO: Consider how to implement c -
    setenv ___X_CMD_XBINEXP_INITENV_OLDPWD "$OLDPWD"
    alias c 'x cd'

    alias xg 'x git'

    alias , 'x tcsh --sysco'
    # alias xd 'x docker'

    # set filec
    # set autolist

    # set autolist = ambiguous
    # set complete = enhance
endif
