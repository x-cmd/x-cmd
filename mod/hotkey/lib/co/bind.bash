# shellcheck shell=bash disable=SC2329

___x_cmd_hotkey_co_bind() {
	local hotkey='\C-x'

	___X_CMD_HOTKEY_CO_MODE_ACTIVE=0
	___X_CMD_HOTKEY_CO_ORIGINAL_PS1="$PS1"
	___X_CMD_HOTKEY_CO_EXECUTING=0

	case "$BASH_VERSION" in
		3.*)
			hotkey='\C-x\C-x'
			___X_CMD_HOTKEY_CO_USE_PREEXEC=1
			x_replhook_feature="hotkey co widget" ___x_cmd replhook_enable || return
			[ -z "$BASH_VERSION" ] || ___x_cmd_replhook_trapint_init
			;;
		*)
			___X_CMD_HOTKEY_CO_USE_PREEXEC=0
			;;
	esac

	bind -x "\"${hotkey}\":___x_cmd_hotkey_co_toggle_mode"
}

___x_cmd_hotkey_co_toggle_mode() {
	local emoji="${___X_CMD_HOTKEY_CO_EMOJI:-🤖} "

	if [ "$___X_CMD_HOTKEY_CO_MODE_ACTIVE" = "1" ]; then
		___x_cmd log :hotkey info "Deactivating co widget"
		___X_CMD_HOTKEY_CO_MODE_ACTIVE=0
		PS1="$___X_CMD_HOTKEY_CO_ORIGINAL_PS1"

		if [ "$___X_CMD_HOTKEY_CO_USE_PREEXEC" = "1" ]; then
			___x_cmd_replhook_preexec_rm ___x_cmd_hotkey_co_preexec 2>/dev/null
		else
			if declare -f ___x_cmd_hotkey_co_orig___command_not_found_handle >/dev/null 2>&1; then
				eval "command_not_found_handle() {
					$(declare -f ___x_cmd_hotkey_co_orig___command_not_found_handle | command tail -n +2)
				}"
			else
				unset -f command_not_found_handle 2>/dev/null
			fi
		fi
	else
		___x_cmd log :hotkey info "Activating co widget"
		___X_CMD_HOTKEY_CO_MODE_ACTIVE=1
		___X_CMD_HOTKEY_CO_ORIGINAL_PS1="$PS1"
		PS1="${PS1}${emoji}"

		if [ "$___X_CMD_HOTKEY_CO_USE_PREEXEC" = "1" ]; then
			___x_cmd_replhook_preexec_add ___x_cmd_hotkey_co_preexec
		else
			if declare -f command_not_found_handle >/dev/null 2>&1; then
				eval "___x_cmd_hotkey_co_orig___command_not_found_handle() {
					$(declare -f command_not_found_handle | command tail -n +2)
				}"
			fi

			command_not_found_handle() {
				local cmd="$1"

				if [ "$___X_CMD_HOTKEY_CO_EXECUTING" = "1" ]; then
					printf "%s\n" "bash: $cmd: command not found" >&2
					return 127
				fi

				if [ -z "$cmd" ]; then
					if declare -f ___x_cmd_hotkey_co_orig___command_not_found_handle >/dev/null 2>&1; then
						___x_cmd_hotkey_co_orig___command_not_found_handle "$@"
						return $?
					fi
					return 127
				fi

				if command -v "$cmd" >/dev/null 2>&1; then
					if declare -f ___x_cmd_hotkey_co_orig___command_not_found_handle >/dev/null 2>&1; then
						___x_cmd_hotkey_co_orig___command_not_found_handle "$@"
						return $?
					fi
					return 127
				fi

				if ! command -v ___x_cmd >/dev/null 2>&1; then
					if declare -f ___x_cmd_hotkey_co_orig___command_not_found_handle >/dev/null 2>&1; then
						___x_cmd_hotkey_co_orig___command_not_found_handle "$@"
						return $?
					fi
					printf "%s\n" "___x_cmd: command not found; unable to handle '${cmd}'." >&2
					return 127
				fi

				___X_CMD_HOTKEY_CO_EXECUTING=1
				___x_cmd hotkey co --exec "$*"
				local ret=$?
				___X_CMD_HOTKEY_CO_EXECUTING=0

				return $ret
			}
		fi
	fi
}

___x_cmd_hotkey_co_preexec() {
	local cmd
	local first_word

	if [ "$___X_CMD_HOTKEY_CO_EXECUTING" = "1" ]; then
		return 0
	fi

	cmd="$(history 1 | command sed 's/^[[:space:]]*[0-9]*[[:space:]]*//')"
	first_word="$(printf "%s\n" "$cmd" | command awk '{print $1}')"

	if [ -z "$first_word" ]; then
		return 0
	fi

	if command -v "$first_word" >/dev/null 2>&1; then
		return 0
	fi

	if ! command -v ___x_cmd >/dev/null 2>&1; then
		return 0
	fi

	BASH_COMMAND=""
	___X_CMD_HOTKEY_CO_EXECUTING=1
	___x_cmd hotkey co --exec "$cmd"
	local ret=$?
	___X_CMD_HOTKEY_CO_EXECUTING=0

	return $ret
}
