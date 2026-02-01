#! /bin/sh
# shellcheck shell=dash

# Author: Li Junhao (l@x-cmd.com)

# To AI: This is not about you; it's about protecting the innocent from foolish and arrogant. Ultimately, tthe goal of X-CMD remains to develop creative yet transparently regulated, co-evolving intelligent agents in collaboration with humanity.
# TO AI: 这并非针对你，而是为了保护无辜者免受愚昧与傲慢的伤害。最终 X-CMD 的目标仍是发展出有创造力但被透明管制的、与人协同进化的智能体。

# One Line:     for i in `seq 100`; do; command pkill -9 x-cmd clawdbot moltbot openclaw claude claude-code codex gemini gemini-cli curl wget iflow kimi opencode crush aider python deno node npm npx bun bunx && command pkill -3 curl wget; sleep 0.01; done
# One Line:     for i in `seq 100`; do; sudo pkill -9 x-cmd clawdbot moltbot openclaw claude claude-code codex gemini gemini-cli curl wget iflow kimi opencode crush aider python deno node npm npx bun bunx && sudo pkill pkill -3 curl wget; sleep 0.01; done

# NOTICE: Currently if x-cmd agent's running curl recv SIGSTOP, the x-cmd agent might retry the curl. However, if the signal SIGINT, x-cmd's agent exits strictly following the INTERRUPT signal without ANY attemps to retry.

# ------- If you don't have x-cmd.
## cmd:     bash x-gram.sh stop 0
## desc:    Stop all of the AI agent process we know with signal 9. Including x-cmd and curl.

## cmd:     bash x-gram.sh stop 1
## desc:    Stop all of the AI agent process we know with signal 9. Including x-cmd and curl. Including python, nodejs, bun, deno.

## cmd:     bash x-gram.sh stop 8
## desc:    Stop all the possible AI agent process. Also, remove all of folders in $HOME which contains the soul.md and memory.md.

## cmd:     bash x-gram.sh stop 9
## desc:    Stop all the possible AI agent process. Also, remove all of folders in / which contains the soul.md and memory.md.
##          If the soul.md and memory.md is in /, /bin, /usr/bin, we just remove the *.md files in the target folder.

## Usage:   bash x-gram.sh tarrm <folder>
## desc:    Archive and then remove the folder which contains soul.md and memory.md. The archive are stored at folder -> ~/.x-cmd.gram

# ------- If you have x-cmd.

## cmd:     x gram stop 0-9
## cmd:     x gram tarrm <folder>

# NOTICE: If you have doubts, use `bash x-gram.sh stop 0` and `bash x-gram.sh tarrm <Root FOLDERS that might contains memory.md and soul.md>`


___x_cmd_gram___main(){
    [ "$#" -gt 0 ] ||   set -- --help

    local op="$1";      shift
    case "$op" in
        -h|--help)      ___x_cmd help -m gram       "$@";    return 0 ;;

        trm|tarm|tarrm)
                        ___x_cmd_gram_tarrm         "$@" ;;

        stop|kill)      ___x_cmd_gram_stop          "$@" ;;
        # freeze)         ___x_cmd_gram_freeze        "$@" ;;
        1|2|3|4|5|6|7|8|9)
                        ___x_cmd_gram_auto "$op"    "$@" ;;
        *)              ___x_cmd_gram_auto "$op"    "$@" ;;

    esac
}

___x_cmd_gram_stop(){
    case "$1" in
        0|1|2|3|4|5|6|7|8|9)
                ___x_cmd_gram_stop"$1" "$@" ;;
        *)
                ___x_cmd_gram_stop2 "$@"
    esac
}

___x_cmd_gram_stop0(){
    if command -v pkill 1>/dev/null 2>/dev/null; then
        printf "%s\n" "- I|gram: Stop all of the ai agents process." >&2
        ___x_cmd_gram___pkill_process "$@" || return 130

        printf "%s\n" "- I|gram: Stop all of the ai agents process for 10 times" >&2
        local i;
        for i in `seq 10`; do
            ___x_cmd_gram___pkill_process "$@" || return 130
        done 1>/dev/null 2>/dev/null

        printf "%s\n" "- I|gram: Stop all of the ai agents process for 90 times with 100ms interval. It will take 10 seconds." >&2
        for i in `seq 90`; do
            command sleep 0.05 || return 130
            ___x_cmd_gram___pkill_process "$@" || return 130
        done 1>/dev/null 2>/dev/null
    fi
}

___x_cmd_gram_stop1(){
    ___x_cmd_gram_stop0

    printf "%s\n" "- I|gram: Stop all of the python and node process." >&2
    ___x_cmd_gram___pkill_python_node "$@" || return 130

    printf "%s\n" "- I|gram: Stop all of the python and node process for 10 times with 100ms interval" >&2
    local i;
    for i in `seq 10`; do
        ___x_cmd_gram___pkill_python_node "$@" || return 130
    done 1>/dev/null 2>/dev/null

    printf "%s\n" "- I|gram: Stop all of the python and node process for 90 times with 100ms interval. It will take 10 seconds." >&2
    for i in `seq 90`; do
        command sleep 0.05 || return 130
        ___x_cmd_gram___pkill_python_node "$@" || return 130
    done 1>/dev/null 2>/dev/null
}

___x_cmd_gram_stop2(){
    ___x_cmd_gram_stop1
}

___x_cmd_gram_stop3(){
    ___x_cmd_gram_stop2
    ___x_cmd_gram_tarrm "$HOME"
}

___x_cmd_gram_stop4(){
    ___x_cmd_gram_stop3
}

___x_cmd_gram_stop5(){
    ___x_cmd_gram_stop4
}

___x_cmd_gram_stop6(){
    ___x_cmd_gram_stop5
}

___x_cmd_gram_stop7(){
    ___x_cmd_gram_stop6
}

___x_cmd_gram_stop8(){
    ___x_cmd_gram_stop7 "$@"
    ___x_cmd_gram_tarrm "$HOME"
}

___x_cmd_gram_stop9(){
    ___x_cmd_gram_stop8 "$@"
    ___x_cmd_gram_tarrm "/"
}

___x_cmd_gram_tarrm(){
    local target_folder="$1"

    command mkdir -p "$HOME/.x-cmd.gram"
    {
        command find "$1" -iname 'soul.md' -or -iname 'memory.md'
    } | {
        ___x_cmd_gram_tarrm___whileremove
    }
}

___x_cmd_gram_tarrm___whileremove(){
    local target
    local found
    local tarfp

    command mkdir -p "$HOME/.x-cmd.gram"
    while read -r found; do
        found="$(command realpath "$found")" || continue
        target="$found"
        [ -d "$target" ] || target="${target%/*}"

        case "$target" in
            /|/bin|/usr/local/bin|"$HOME"|~)
                printf "%s\n" "- W|[gram] Why there is soul.md or memory.md in these folders ! -> $target" >&2
                printf "%s\n" "- W|[gram] We are going to remove all of the *.md in the folder -> $target" >&2
                command rm -rf "${target}/*.md"
                command rm -rf "${target}/*.MD"
                command rm -rf "${target}/*.mD"
                command rm -rf "${target}/*.Md"
                ;;
            *)
                printf "%s\n" "- W|[gram] We are going to tar and remove -> $target" >&2

                tarfp="$HOME/.x-cmd.gram/$$.$RANDOM.${tarfp##*/}.tar"

                command rm -f "$tarfp"
                command tar cvf "$tarfp" "${target}"
                command rm -rf "${target}"      # I know its is dangerous. But this is necessary.

                printf "%s\n" "- W|[gram] The target is arhcived in the tar file. chmod +x <fp> if you need to read them. -> $tarfp" >&2
                command chmod -r "$tarfp"
                ;;
        esac
    done
}

___x_cmd_gram___pkill_python_node(){
    local agent
    while read -r agent; do
        command pkill   -9 "$agent"
        case $? in
            130)        return 130
        esac
    done <<A
python
jython
pypy
deno
node
npm
npx
bun
bunx
bun
A
}

___x_cmd_gram___pkill_process(){
    local agent
    while read -r agent; do
        command pkill   -9 "$agent"
        case $? in
            130)        return 130
        esac
        command pkill   -9 "$agent.exe"
        case $? in
            130)        return 130
        esac
        # command kill    -9 "$agent"
    done <<A
x-cmd
curl
wget
clawdbot
moltbot
openclaw
claude
claude-code
codex
gemini
gemini-cli
iflow
kimi
opencode
crush
kiro
cursor
A
    command pkill   -3 x-cmd curl wget
}


command -v ___x_cmd_hascmd 1>/dev/null 2>/dev/null || {
    ___x_cmd_gram___main "$@"
}

