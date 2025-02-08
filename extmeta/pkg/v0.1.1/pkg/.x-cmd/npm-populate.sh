# shellcheck shell=dash
. "$___X_CMD_PKG_METADATA_PATH/.x-cmd/gen_shim_file.sh"

___x_cmd_pkg___npm_populate()(

    local ___X_CMD_PKG_RUNTIME_NODE_VERSION="v22.11.0"
    case "$1" in
        --node_version)
            ___X_CMD_PKG_RUNTIME_NODE_VERSION="$2"; shift 2;;
    esac

    log:sub:init -i "$___X_CMD_PKG___META_NAME ${___X_CMD_PKG___META_VERSION#v}" x_cmd_pkg "npm populate"
    x_cmd_pkg:info "Set up node environment => $___X_CMD_PKG_RUNTIME_NODE_VERSION"
    (
        x pkg sphere path add \
            --sphere "$___X_CMD_PKG___META_SPHERE_NAME"                      \
            --osarch "$___X_CMD_PKG___META_OS/$___X_CMD_PKG___META_ARCH"    \
            node "${___X_CMD_PKG_RUNTIME_NODE_VERSION}"                     \
        || return 1

        x hascmd node || return 1
        x hascmd npm || return 1

        ___x_cmd_pkg___npm_populate_install || {
            x_cmd_pkg:error "npm install $___X_CMD_PKG___META_NAME"
            return
        }
        x_cmd_pkg:info  "npm runtime successfully"
    ) || return

    ___x_cmd_pkg___npm_gen_shim_bin "$@" || return

    log:sub:fini
)

# 包名和 npm 安装使用的包名如果不一致，则重写 ___x_cmd_pkg___npm_populate_install 函数
___x_cmd_pkg___npm_populate_install(){
    local pkg_install_name="$___X_CMD_PKG___META_NAME"

    local x_=
    if x pkg websrc npm_ 2>/dev/null || true; then
        npm install                                          \
            --prefix "$___X_CMD_PKG___META_TGT"              \
            "$pkg_install_name@${___X_CMD_PKG___META_VERSION#v}" \
            --registry="$x_"                                 \
        || return 1
    fi
}

___x_cmd_pkg___npm_gen_shim_bin(){
    [ "$#" -ge 1 ] || return 1

    local node_mod_path=; local x_treename=; local runtime_bin_path=

    ___x_cmd_pkg_treename_ node "$___X_CMD_PKG_RUNTIME_NODE_VERSION" "$___X_CMD_PKG___META_OS/$___X_CMD_PKG___META_ARCH" || return
    runtime_bin_path="$___X_CMD_PKG_ROOT_SPHERE/$___X_CMD_PKG___META_SPHERE_NAME/$x_treename/node/$___X_CMD_PKG_RUNTIME_NODE_VERSION/bin" #TODO: shims
    node_mod_path="$___X_CMD_PKG___META_TGT/node_modules"

    ___x_cmd_pkg_shim_gen                                   \
        --mode app                                          \
        --code sh                                           \
        --var "NODE_PATH=${node_mod_path}:\$NODE_PATH"      \
        --var "PATH=$runtime_bin_path:\$PATH"               \
        --bin_dir "node_modules/.bin"                       \
        --bin_file "$@"                                     \
    || return

    if [ "$___X_CMD_PKG___META_OS" = "win" ]; then
        ___x_cmd_pkg_shim_gen                               \
            --mode app                                      \
            --code bat                                      \
            --var "NODE_PATH=${node_mod_path};\$NODE_PATH"  \
            --var "PATH=$runtime_bin_path:\$PATH"           \
            --bin_dir "node_modules/.bin"                   \
            --bin_file "$@"                                 \
        || return
    fi
}

