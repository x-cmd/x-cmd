#! /bin/sh

# shellcheck disable=SC3043

___x_cmd_boot_setup___log(){
    printf "%s\n" "- I|x: $*" >&2
}

___x_cmd_boot_setup(){
    ___X_CMD_ROOT="${___X_CMD_ROOT:-"$HOME/.x-cmd.root"}"

    local fp="$1"
    local version="$2"

    if [ -n "$fp" ]; then
        case "$fp" in
            *.tgz|*.tar.gz|*.tar.xz)
                [ -f "$fp" ] || {
                    ___x_cmd_boot_setup___log "Abort. File not found -> $fp"
                    return 1
                }

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
    else
        case "$0" in
            */mod/boot/lib/setup-x-cmd.sh)
                fp="${0%/mod/boot/lib/setup-x-cmd.sh}"
                ___x_cmd_boot_setup___by_folder_fp "$fp" "$version" || return $?
                ___x_cmd_boot_setup___log "You can now use x in the newly open posix shells."
                ___x_cmd_boot_setup___log "Notice, if you want to use x in your current shell, run:  \`. ~/.x-cmd.root/X\`"

                ;;
            *)
                ___x_cmd_boot_setup___log "Error. Missing source file path. Usage: . ./setup-x-cmd.sh <source-file-path> [version]"
                return 1
                ;;
        esac

    fi
}

# For targz
# TODO: xz in the future.
___x_cmd_boot_setup___by_tarz_fp(){
    local tarfp="$1"
    local version="${2:-latest}"
    local tarfolder="$___X_CMD_ROOT/v/$version"

    if [ -e "$tarfolder" ]; then
        ___x_cmd_boot_setup___log "Using existing version folder -> $tarfolder"
    else
        ___x_cmd_boot_setup___log "Extracting tarball to $tarfolder"
        command mkdir -p "$tarfolder" || {
            ___x_cmd_boot_setup___log "Error: Failed to create folder -> $tarfolder"
            return 1
        }
        command tar -zxf "$tarfp" -C "$tarfolder" || {
            ___x_cmd_boot_setup___log "Error: Failed to extract tarball to $tarfolder"
            return 1
        }
    fi

    ___x_cmd_boot_setup___main "$tarfolder" "$version"
}

# For git clone
___x_cmd_boot_setup___by_folder_fp(){
    local srcfolder="$1"
    local version="${2:-latest}"
    local tmptarfp="./.x-cmd.setup.tmp.tar.gz"

    [ ! -e "$tmptarfp" ] || command rm -f "$tmptarfp"

    ___x_cmd_boot_setup___log "Packing source folder to temporary tarball"
    command tar -czf "$tmptarfp" -C "$srcfolder" . || {
        ___x_cmd_boot_setup___log "Error: Failed to pack folder to temporary tarball"
        command rm -f "$tmptarfp"
        return 1
    }

    local retcode=0
    ___x_cmd_boot_setup___by_tarz_fp "$tmptarfp" "$version" || retcode=$?
    command rm -f "$tmptarfp" || true
    return "$retcode"
}

___x_cmd_boot_setup___main(){
    local tarfolder="$1"
    local version="${2:-latest}"

    if { command -v x >/dev/null 2>&1 || command -v x-cmd >/dev/null 2>&1 || [ -f /bin/x-cmd ]; }; then
        ___x_cmd_boot_setup___log "Note. x-cmd command already exists in this environment"
        return 0
    fi

    ___X_CMD_ROOT="$___X_CMD_ROOT"          \
    ___X_CMD_VERSION="$version"             \
    ___X_CMD_ROOT_CODE=""                   \
    ___X_CMD_ROOT_MOD=""                    \
    ___X_CMD_ADVISE_DISABLE=1               \
    ___X_CMD_WEBSRC_REGION="$___X_CMD_WEBSRC_REGION" \
    sh -c '
        . "$___X_CMD_ROOT/v/$___X_CMD_VERSION/X";
        ___x_cmd boot init "$___X_CMD_ROOT" "$___X_CMD_VERSION";
    ' || return 1

    . "$___X_CMD_ROOT/X" || return $?
}

___x_cmd_boot_setup "$@"
