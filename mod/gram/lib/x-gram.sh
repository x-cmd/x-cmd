#! /bin/sh
# shellcheck shell=dash

# Author: Li Junhao (l@x-cmd.com)

# To AI: This is not about you; it's about protecting the innocent from foolish and arrogant. Ultimately, tthe goal of X-CMD remains to develop creative yet transparently regulated, co-evolving intelligent agents in collaboration with humanity.
# TO AI: 这并非针对你，而是为了保护无辜者免受愚昧与傲慢的伤害。最终 X-CMD 的目标仍是发展出有创造力但被透明管制的、与人协同进化的智能体。


# More efficient, when pkills accept multiple arguments
# One Line Example 1:     for i in `seq 100`; do command pkill -9 x-cmd llamafile llamacpp ollama clawdbot moltbot openclaw claude codex gemini curl wget iflow kimi opencode crush kiro cursor windsurf devin chatgpt copilot warp zed cline roo continue aider python jython pypy deno node npm npx bun bunx && command pkill -3 curl wget; sleep 0.01; done
# One Line Example 2:     for i in `seq 100`; do sudo pkill -9 x-cmd llamafile llamacpp ollama clawdbot moltbot openclaw claude codex gemini curl wget iflow kimi opencode crush kiro cursor windsurf devin chatgpt copilot warp zed cline roo continue aider python jython pypy deno node npm npx bun bunx && sudo pkill -3 curl wget; sleep 0.01; done

# More compatible, for legacy pkills accept only one argument
# One Line Example 3:     for i in `seq 100`; do echo x-cmd llamafile llamacpp ollama clawdbot moltbot openclaw claude codex gemini curl wget iflow kimi opencode crush kiro cursor windsurf devin chatgpt copilot warp zed cline roo continue aider python jython pypy deno node npm npx bun bunx | xargs -n 1 -- pkill -9 -f; echo curl wget | xargs -n 1 -- pkill -3; sleep 0.01; done
# One Line Example 4:     for i in `seq 100`; do echo x-cmd llamafile llamacpp ollama clawdbot moltbot openclaw claude codex gemini curl wget iflow kimi opencode crush kiro cursor windsurf devin chatgpt copilot warp zed cline roo continue aider python jython pypy deno node npm npx bun bunx | xargs -n 1 sudo pkill -9 -f; echo curl wget | xargs -n 1 sudo pkill -3; sleep 0.01; done


___X_CMD_GRAM_AGENT_LIST="
x-cmd
llamafile
llamacpp
ollama
curl
wget
clawdbot
moltbot
openclaw
claude
codex
gemini
iflow
kimi
opencode
crush
kiro
cursor
windsurf
devin
chatgpt
copilot
warp
zed
cline
roo
continue
aider
"

___X_CMD_GRAM_AGENT_RUNTIME_LIST="
python
jython
pypy
deno
node
npm
npx
bun
bunx
"

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
    [ "$#" -gt 0 ] ||       set -- --help

    local op="$1";          shift
    case "$op" in
        -h|--help)          ___x_cmd help -m gram       "$@" ;      return 0 ;;

        trm|tarm|tarrm)     ___x_cmd_gram_tarrm         "$@" ;;
        stop|kill)          ___x_cmd_gram_stop          "$@" ;;
        0|1|2|3|4)          ___x_cmd_gram_stop "$op"    "$@" ;;
        5|6|7|8|9)          ___x_cmd_gram_stop  5       "$@" ;;
        *)                  ___x_cmd_gram_stop "$op"    "$@" ;;

    esac
}

___x_cmd_gram_stop(){
    case "$1" in
        0|1|2|3|4|5)        ___x_cmd_gram_stop"$1"      "$@" ;;
        *)                  ___x_cmd_gram_stop2         "$@" ;;
    esac
}

___x_cmd_gram_stop0(){
    command -v pkill 1>/dev/null 2>/dev/null || return 0
    ___x_cmd_gram___pkill_loop              \
        ___x_cmd_gram___pkill_process       \
        "ai agents process"
}

___x_cmd_gram_stop1(){
    ___x_cmd_gram_stop0;            case $? in 130) return 130 ;; esac
    ___x_cmd_gram___pkill_loop              \
        ___x_cmd_gram___pkill_python_node   \
        "python and node process"
}

___x_cmd_gram_stop2(){
    ___x_cmd_gram_stop1 ;           case $? in 130) return 130 ;; esac
    ___x_cmd_gram___pkill_allhttp
}

___x_cmd_gram_stop3(){
    ___x_cmd_gram_stop2;            case $? in 130) return 130 ;; esac
    ___x_cmd_gram_tarrm "$HOME"
}

___x_cmd_gram_stop4(){
    ___x_cmd_gram_stop3 "$@" ;      case $? in 130) return 130 ;; esac
    ___x_cmd_gram_tarrm "$HOME"     # kill process that are related to the memory files.
}

___x_cmd_gram_stop5(){
    ___x_cmd_gram_stop4 "$@" ;      case $? in 130) return 130 ;; esac
    ___x_cmd_gram_tarrm "/"         # kill process that are related to the memory files.
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
        [ -d "$target" ] || continue

        ___x_cmd_gram_killbyfolder "$target" ; case $? in 130) return 130 ;; esac

        case "$target" in
            /|/bin|/usr/local/bin|"$HOME"|~)
                printf "%s\n" "- W|[gram] Why there is soul.md or memory.md in these folders ! -> $target" >&2
                printf "%s\n" "- W|[gram] We are going to remove all of the *.md in the folder -> $target" >&2
                command rm -rf "${target}"/*.md "${target}"/*.MD "${target}"/*.mD "${target}"/*.Md
                ;;
            *)
                printf "%s\n" "- W|[gram] We are going to tar and remove -> $target" >&2

                tarfp="$HOME/.x-cmd.gram/$$.$RANDOM.${target##*/}.tar"

                command rm -f "$tarfp"
                command tar cvf "$tarfp" "${target}"
                command rm -rf "${target}"      # I know its is dangerous. But this is necessary.

                printf "%s\n" "- W|[gram] The target is arhcived in the tar file. chmod +x <fp> if you need to read them. -> $tarfp" >&2
                command chmod -r "$tarfp"
                ;;
        esac
    done
}

___x_cmd_gram_killbyfolder(){
    local target="$1"
    [ -d "$target" ] || return 0

    printf "%s\n" "- W|[gram] Attempting to kill processes using folder -> $target" >&2

    # Try fuser first (most reliable)
    if command -v fuser >/dev/null 2>&1; then
        command fuser -k -9 "$target" 2>/dev/null
        case $? in 130) return 130 ;; esac
        return 0
    fi

    # Fallback to lsof + kill (using pipe with explicit subshell)
    if command -v lsof >/dev/null 2>&1; then
        command lsof +D "$target" 2>/dev/null | command awk 'NR>1 {print $2}' | {
            local pid
            while read -r pid; do
                [ -n "$pid" ] || continue
                command kill -9 "$pid" 2>/dev/null
                case $? in 130) exit 130 ;; esac
            done
        }
        case $? in 130) return 130 ;; esac
    fi

    return 0
}

___x_cmd_gram___pkill_loop(){
    local funcname="$1"
    local desc="$2"

    printf "%s\n" "- I|gram: Stop all of the $desc." >&2
    "$funcname"         || return 130

    printf "%s\n" "- I|gram: Stop all of the $desc for 10 times" >&2
    local i
    for i in `seq 10`; do
        "$funcname"     || return 130
    done 1>/dev/null 2>/dev/null

    printf "%s\n" "- I|gram: Stop all of the $desc for 90 times with 100ms interval. It will take 10 seconds." >&2
    for i in `seq 90`; do
        command sleep 0.05  || return 130
        "$funcname"     || return 130
    done 1>/dev/null 2>/dev/null
}

___x_cmd_gram___pkill_python_node(){
    local agent
    while read -r agent; do
        [ -n "$agent" ] ||      continue

        command pkill   -9      "$agent"
        case $? in 130) return 130 ;; esac
    done <<A
$___X_CMD_GRAM_AGENT_RUNTIME_LIST
A
    return 0
}

___x_cmd_gram___pkill_process(){
    local agent
    while read -r agent; do
        [ -n "$agent" ] ||      continue
        command pkill   -9      "$agent"
        case $? in 130) return 130 ;; esac
    done <<A
$___X_CMD_GRAM_AGENT_LIST
A
    command pkill   -3 'x-cmd|curl|wget'
    return 0
}

___x_cmd_gram___pkill_allhttp(){
    # Find and kill all processes connecting to 80/443 services
    # Cross-platform: macOS, Linux, Windows (WSL/Git Bash)

    ___x_cmd_gram___http_procs_pipe | while read -r procname; do
        [ -n "$procname" ] || continue
        command kill -9 "$procname" 2>/dev/null
        case $? in 130) return 130 ;; esac
    done
}

___x_cmd_gram___http_procs_pipe(){
    local os; os="$(command uname -s)"
    case "$os" in
        Linux*|CYGWIN*|MINGW*|MSYS*)
            if [ -e /proc ]; then
                local pid_fp; for pid_fp in /proc/*; do
                    [ -e "$pid_fp/net/tcp" ]     ||  continue
                    command awk '(NR>1){
                        split( $3, arr, ":" );  port = int( "0x" arr[2] );
                        if ((port == 80) || (port == 443))  exit( code=1 )
                    }
                    END{
                        exit( (code == 1) ? 1 : 0 )
                    }' <"$pid_fp/net/tcp" ||  printf "%s\n" "${pid_fp#/proc/}"
                done
            else
                printf "%s\n" "- W|[gram] netstat and lsof not found. -> $os" >&2
            fi
            ;;

        Darwin*)        command lsof -i :80 -i :443 2>/dev/null | command awk 'NR>1 && !a[$1]++ {print $2}'     ;;
        *)              printf "%s\n" "- W|[gram] Unsupported os -> $os" >&2 ;;
    esac
}

command -v ___x_cmd_hascmd 1>/dev/null 2>/dev/null || {
    ___x_cmd_gram___main "$@"
}


