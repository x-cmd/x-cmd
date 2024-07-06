# add path to .x-cmd.root/bin and .x-cmd.root/global/data/bin/l/j/h

# TODO: improve this ...
if ( "$PATH" !~ *$HOME/.x-cmd.root/bin* ) then
    setenv PATH $HOME/.x-cmd.root/bin:$HOME/.x-cmd.root/local/data/bin/l/j/h/bin:$PATH
endif

setenv  ___X_CMD_CD_RELM_0      "$PWD"

# alias x             bash "$HOME/.x-cmd.root/bin/xbin"
# alias ___x_cmd      bash "$HOME/.x-cmd.root/bin/xbin"

alias ___x_cmd      source "$HOME/.x-cmd.root/bin/rc.x.tcsh"
alias x             ___x_cmd


# TODO: in the future, adding the advise

setenv CSH_VERSION "${version}"

setenv ___X_CMD_IS_INTERACTIVE_FORCE 1
setenv ___X_CMD_THEME_RELOAD_DISABLE 1

# "$HOME/.x-cmd.root/bin/xbin" prepare alias
if ($?status && $status == 0) then
    # set filec
    # set autolist

    # set autolist = ambiguous
    # set complete = enhance

    # TODO: Consider how to implement c -
    setenv ___X_CMD_XBINEXP_INITENV_OLDPWD "$OLDPWD"

    alias c     '___x_cmd cd'

    alias xx    '___x_cmd xx'
    alias xw    '___x_cmd ws'

    alias xd    '___x_cmd docker'
    alias xg    '___x_cmd git'
    alias xp    '___x_cmd pwsh'

    alias ,     '___x_cmd tcsh --sysco'
    alias ，    '___x_cmd tcsh --sysco'
    # alias ,,    '___x_cmd tcsh --syscoco'
    # alias ，，  '___x_cmd tcsh --syscoco'


    # eval "`___x_cmd chat --aliasinit --cshcode`"
    alias @          '___x_cmd chat --sendalias ""'
    alias @l         '___x_cmd chat --sendalias l'
    alias @lms       '___x_cmd chat --sendalias lms'
    alias @o         '___x_cmd chat --sendalias o'

    alias @gpt       '___x_cmd chat --sendalias gpt'
    alias @gpt3      '___x_cmd chat --sendalias gpt3'
    alias @gpt4      '___x_cmd chat --sendalias gpt4'

    alias @kimi      '___x_cmd chat --sendalias kimi'
    alias @gemini    '___x_cmd chat --sendalias gemini'
    alias @mistral   '___x_cmd chat --sendalias mistral'

    #  writer, w
    alias @zh        '___x_cmd writer --sendalias zh'
    alias @en        '___x_cmd writer --sendalias en'

endif
