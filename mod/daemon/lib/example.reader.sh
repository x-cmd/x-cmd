#! /usr/bin/env sh

. "${___X_CMD_ROOT}/v/${___X_CMD_VERSION}/X"

main(){
    local cmd
    while true; do
        cmd="$(cat "${fifo}")"
        local code=$?
        case "$code" in
            0)         ;;
            130)    printf "Recv interruption." ;   return ;;
            *)      printf "Recv %s" "$code" ;      break ;;
        esac

        case "$cmd" in
            work\ :*)        ;;
        esac
    done
}

x daemon proc run main "$@"
