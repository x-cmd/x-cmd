# ___X_CMD_ROOT="$(x wsroot)"
# ___X_CMD_ROOT_MOD="$(x wsroot)/mod"
. "${___X_CMD_ROOT_MOD}/xrc/latest"

build_demo(){
    local p=adv/demo
    [ -d "$p" ] || return
    x mkdirp ".demo"
    local i; for i in "${p}"/*.yml; do
        name="${i##*/}"
        name="${name%.yml}"
        x:info "x script apply $i .demo/${name}.speg"
        # x script apply "$i" ".demo/${name}.speg"
    done
}

xrc advise
xrc script
for mod in "$@"; do
    (
        x:info "Module for $mod"
        x:debug "Getting into $___X_CMD_ROOT_MOD/$mod"
        x cd "$___X_CMD_ROOT_MOD/$mod" || {
            x:error "Fail to cd: $___X_CMD_ROOT_MOD/$mod"
            exit 1
        }
        x:info "Starting scotty build."
        x scotty mod build0
        [ "$?" = 0 ] || {
            x:error "Fail to generate jso: $mod"
            # TODO: exit 1 in the future
        }
        # x:info "Finish scotty build."
        if [ ! -f "res/advise.jso" ]; then
            x:error "Finish scotty build but res/advise.jso NOT found."
            x touch res/advise.jso
            printf "%s\n%s\n" "{" "}" > res/advise.jso
            # exit 1
        fi

        x:info "Finish scotty build."

        build_demo

        x:info "Finish scotty build_demo."
    )
    [ "$?" = 0 ] || exit 1
done
