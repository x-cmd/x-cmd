# shellcheck shell=dash
. "$___X_CMD_PKG_METADATA_PATH/.x-cmd/gen_shim_file.sh"

___x_cmd_pkg___pip_populate()(
    local ___X_CMD_PKG_RUNTIME_PYTHON_VERSION="v3.10.0+23.9.0-0"
    case "$1" in
        --python_version)
            ___X_CMD_PKG_RUNTIME_PYTHON_VERSION="$2"; shift 2;;
    esac

    log:sub:init -i "$___X_CMD_PKG___META_NAME ${___X_CMD_PKG___META_VERSION#v}" x_cmd_pkg "pip populate"
    ___x_cmd_pkg___pip_populate_generate_venv   || return
    ___x_cmd_pkg___pip_gen_shim_bin "$@"        || return
    log:sub:fini
)

___x_cmd_pkg___pip_populate_generate_venv(){

    x_cmd_pkg:info "step 1/3, Set up python environment: $___X_CMD_PKG_RUNTIME_PYTHON_VERSION"
    (
        x pkg sphere path add \
            --sphere "$___X_CMD_PKG___META_SPHERE_NAME"                      \
            --osarch "$___X_CMD_PKG___META_OS/$___X_CMD_PKG___META_ARCH"    \
            miniconda "$___X_CMD_PKG_RUNTIME_PYTHON_VERSION"                   \
        || return 1

            #1>&2 2>/dev/null

        local bin_dir="bin"
        [ "$___X_CMD_PKG___META_OS" != "win" ]      || bin_dir="Scripts"

        x mkdirp "$___X_CMD_PKG___META_TGT"
        x_cmd_pkg:info "step 2/3, python -m venv $___X_CMD_PKG___META_TGT"
        command -v python >/dev/null || {
            x_cmd_pkg:error "python not found"
            return 1
        }
        python -m venv "$___X_CMD_PKG___META_TGT"   || {
            x_cmd_pkg:error "python -m venv $___X_CMD_PKG___META_TGT failure"
            return 1
        }

        x_cmd_pkg:info "step 3/3, pip install package $___X_CMD_PKG___META_NAME==${___X_CMD_PKG___META_VERSION#v}"
        ___x_cmd_pkg___pip_populate_install_dep "$bin_dir" || return
        ___x_cmd_pkg___pip_populate_install     "$bin_dir" || return

        # TODO：当前只有 jieba 需要
        ___x_cmd_pkg___pip_gen_shellbin         "$bin_dir" || return
    ) || return 1
    x_cmd_pkg:info "pip successfully"
}

___x_cmd_pkg___pip_populate_install(){
    local pkg_install_name="$___X_CMD_PKG___META_NAME"
    local bin_dir="$1"

    local x_=
    if x pkg websrc pip_ 2>/dev/null || true; then
        "$___X_CMD_PKG___META_TGT/$bin_dir/pip" install \
            --require-virtualenv                                  \
            "$pkg_install_name==${___X_CMD_PKG___META_VERSION#v}" \
            -i "$x_"
    fi
}

___x_cmd_pkg___pip_gen_shellbin(){
    :
}

___x_cmd_pkg___pip_populate_install_dep(){
    :
}

___x_cmd_pkg___pip_gen_shim_bin(){
    [ "$#" -ge 1 ] || return 1

    local env_var=;  local x_treename=; local runtime_bin_path=; local bin_dir="bin"
    ___x_cmd_pkg_treename_ miniconda "$___X_CMD_PKG_RUNTIME_PYTHON_VERSION" "$___X_CMD_PKG___META_OS/$___X_CMD_PKG___META_ARCH" || return
    runtime_bin_path="$___X_CMD_PKG_ROOT_SPHERE/$___X_CMD_PKG___META_SPHERE_NAME/$x_treename/miniconda/$___X_CMD_PKG_RUNTIME_PYTHON_VERSION"
    [ "$___X_CMD_PKG___META_OS" != "win" ] || bin_dir="Scripts"
    env_var="$runtime_bin_path/$bin_dir"

    ___x_cmd_pkg_shim_gen               \
        --mode app                      \
        --code sh                       \
        --bin_dir "$bin_dir"            \
        --bin_file "$@"                 \
    || return
        # --var "PATH=$env_var:\$PATH"    \
        # --var "PYTHONPATH=$runtime_bin_path"  \
        # --var "PYTHONHOME=$runtime_bin_path"  \

    if [ "$___X_CMD_PKG___META_OS" = "win" ]; then
        ___x_cmd_pkg_shim_gen               \
            --mode app                      \
            --code bat                      \
            --bin_dir "$bin_dir"            \
            --bin_file "$@"                 \
        || return
    fi
}
