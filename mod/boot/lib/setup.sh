#! /bin/sh

# shellcheck disable=SC3043

___x_cmd_boot_setup___log(){
    printf "%s\n" "- I|x: $*" >&2
}

___x_cmd_boot_setup(){
    ___X_CMD_ROOT="${___X_CMD_ROOT:-"$HOME/.x-cmd.root"}"

    local fp="$1"
    local version="$2"

    case "$fp" in
        *.tgz|*.tar.gz|*.tar.xz)
            ___x_cmd_boot_setup___by_tarz_fp "$fp" "$version"
            ;;
        *)
            [ -d "$fp" ] || {
                ___x_cmd_boot_setup___log "Abort. Expect to be gzip tarball or folder -> $fp"
                return 1
            }

            ___x_cmd_boot_setup___by_folder_fp "$fp" "$version"
            ;;
    esac
}

# For targz
# TODO: xz in the future.
___x_cmd_boot_setup___by_tarz_fp(){
    local tarfp="$1"
    local version="${2:-latest}"

    local tmpfolder="./.x-cmd.setup.tmp.folder"
    [ ! -e "$tmpfolder" ] || rm -rf "$tmpfolder"

    tar xvf "$tarfp" "$tmpfolder"
    local retcode=0
    ___x_cmd_boot_setup___by_folder_fp "$tmpfolder" "$version" || retcode=$?
    rm -rf "$tmpfolder" || true
    return "$retcode"
}

# For git clone
___x_cmd_boot_setup___by_folder_fp(){
    local srcfolder="$1"
    local version="${2:-latest}"

    local versionfp="${srcfolder}/.x-cmd/metadata/version_sum"

    [ -f "${versionfp}" ] || {
        ___x_cmd_boot_setup___log "Exit. Because this is not valid src folder of x-cmd."
        return 1
    }

    # copy folder to the specified folder, with latest
    local versum
    read -r versum <"${versionfp}"
    versum="${versum#*=}"

    local versum8
    versum8="${versum%"${versum#????????}"}"

    mkdir -p "$___X_CMD_ROOT/v" || true
    cp -r "$srcfolder" "$HOME/.x-cmd.root/v/.$versum8" || {
        ___x_cmd_boot_setup___log "Fail to copy folder to $HOME/.x-cmd.root/v"
        return 1
    }

    ___x_cmd_boot_setup___main "$version"
}

___x_cmd_boot_setup___main(){
    ___X_CMD_ROOT="$HOME/.x-cmd.root"
    ___X_CMD_VERSION="${1:-"$___X_CMD_VERSION"}"
    ___X_CMD_WEBSRC_REGION="${2:-"$___X_CMD_WEBSRC_REGION"}"

    ! { command -v x >/dev/null 2>&1 || command -v x-cmd >/dev/null 2>&1 || [ -f /bin/x-cmd ] || [ -f "$___X_CMD_ROOT/X" ]; } || {
        ___x_cmd_boot_setup___log "x-cmd is already installed  in the destination environment for SSH"
        return 0
    }

    [ -n "$___X_CMD_VERSION" ] || {
        ___x_cmd_boot_setup___log "Please specify the version of x-cmd"
        return 1
    }

    local tardir="$___X_CMD_ROOT/v/$___X_CMD_VERSION"
    ___x_cmd_boot_setup___log "Populate x-cmd to $HOME/.x-cmd.root"
    if [ -d "$tardir" ]; then
        ___x_cmd_boot_setup___log "Already existed $tardir"
    else
        local tgzfile="$___X_CMD_ROOT/global/shared/version/archive/$___X_CMD_VERSION.tgz"
        command mkdir -p "$tardir"
        LC_ALL="$___X_CMD_LOCALE_DEF_C" command tar -xzf "$tgzfile" -C "$tardir" || return 1
    fi

    ___X_CMD_ROOT="$___X_CMD_ROOT"          \
    ___X_CMD_VERSION="$___X_CMD_VERSION"    \
    ___X_CMD_ROOT_CODE=""                   \
    ___X_CMD_ROOT_MOD=""                    \
    ___X_CMD_ADVISE_DISABLE=1               \
    ___X_CMD_WEBSRC_REGION="$___X_CMD_WEBSRC_REGION" \
    sh -c '
        . "$___X_CMD_ROOT/v/$___X_CMD_VERSION/X";
        ___x_cmd boot init "$___X_CMD_ROOT" "$___X_CMD_VERSION";
    ' || return 1

    ___X_CMD_ROOT_CODE=;
    . "$___X_CMD_ROOT/v/$___X_CMD_VERSION/X";
}


___x_cmd_boot_setup "$@"

