# shellcheck shell=dash disable=SC2016

___x_cmd_docker_setup___getinfo()(
    ___x_cmd_os_arch_
    printf "%s\n" "x_osname=$___X_CMD_OS_NAME_"
    printf "%s\n" "x_arch=$___X_CMD_OS_ARCH_"

    command -v curl >/dev/null 2>&1 || {
        printf "%s\n" "need_curl=1"
        command mkdir -p /etc/ssl/certs
    }

    command -v awk >/dev/null 2>&1 || {
        printf "%s\n" "need_busybox=1"
    }

    command -v x >/dev/null 2>&1 || command -v x-cmd >/dev/null 2>&1 || [ -f /bin/x-cmd ] || {
        printf "%s\n" "need_x=1"
        printf "%s\n" "need_setup=1"
        command mkdir -p /usr/share/x-cmd/v
    }
)


___x_cmd_os_arch_() {
    [ -z "$___X_CMD_OS_ARCH_" ] || return 0

    local HOST_ARCH

    ___x_cmd_os_name_

    if [ "${___X_CMD_OS_NAME_}" = "sunos" ]; then
        # first try to use pkgsrc to guess the most appropriate arch.
        if HOST_ARCH=$(pkg_info -Q MACHINE_ARCH pkg_install 2>/dev/null); then
            HOST_ARCH=$(echo "${HOST_ARCH}" | command tail -1)
        else
            # If it's not available, use isainfo to get the instruction set supported by the kernel.
            HOST_ARCH=$(isainfo -n)
        fi
    elif [ "${___X_CMD_OS_NAME_}" = "aix" ]; then
        HOST_ARCH=ppc64
    else
        HOST_ARCH="$(command uname -m)"
    fi

    case "${HOST_ARCH}" in
        x86_64 | amd64)     ___X_CMD_OS_ARCH_="x64" ;;
        i*86)               ___X_CMD_OS_ARCH_="x86" ;;
        aarch64)            ___X_CMD_OS_ARCH_="arm64" ;;
        *)                  ___X_CMD_OS_ARCH_="${HOST_ARCH}" ;;     # TODO: Consider 32bit arm? For router or raspberry pi 3?
    esac

    # If running a 64bit ARM kernel but a 32bit ARM userland, change ARCH to 32bit ARM (armv7l)
    if [ "$___X_CMD_OS_NAME_" = "Linux" ] && [ "${___X_CMD_OS_ARCH_}" = arm64 ]; then
        local L
        L=$(command ls -dl /sbin/init 2>/dev/null)                  # if /sbin/init is 32bit executable
        if [ "$(command od -An -t x1 -j 4 -N 1 "${L#*-> }")" = ' 01' ]; then
            ___X_CMD_OS_ARCH_=armv7l
        fi
    fi
}

___x_cmd_os_name_(){
    if [ -z "$___X_CMD_OS_NAME_" ]; then
        case "$(command uname -a)" in
            Linux\ *)                   ___X_CMD_OS_NAME_=linux ;;
            Darwin\ *)                  ___X_CMD_OS_NAME_=darwin ;;
            SunOS\ *)                   ___X_CMD_OS_NAME_=sunos ;;
            FreeBSD\ *)                 ___X_CMD_OS_NAME_=freebsd ;;
            OpenBSD\ *)                 ___X_CMD_OS_NAME_=openbsd ;;         # TODO: Netbsd?
            AIX\ *)                     ___X_CMD_OS_NAME_=aix ;;
            CYGWIN* | MSYS* | MINGW*)   ___X_CMD_OS_NAME_=win ;;
        esac
    fi
}

"$@"
