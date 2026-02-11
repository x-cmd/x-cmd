# shellcheck shell=zsh

___x_cmd_hotkey_co_bind() {
  	local hotkey='\C-x'

	___X_CMD_HOTKEY_CO_MODE_ACTIVE=0
	___X_CMD_HOTKEY_CO_EXECUTING=0
	___X_CMD_HOTKEY_CO_HOTKEY="$hotkey"

	___x_cmd_hotkey_co_setup_widgets
}

___x_cmd_hotkey_co_setup_widgets() {
	zle -N ___x_cmd_hotkey_co_toggle_mode 2>/dev/null

	local km; for km in "emacs" "viins"; do
		bindkey -M "$km" "${___X_CMD_HOTKEY_CO_HOTKEY:-\C-x}" ___x_cmd_hotkey_co_toggle_mode 2>/dev/null
	done

	zle -N zle-line-init ___x_cmd_hotkey_co_line_init 2>/dev/null
	zle -N zle-line-finish ___x_cmd_hotkey_co_line_finish 2>/dev/null
	zle -N zle-line-pre-redraw ___x_cmd_hotkey_co_line_pre_redraw 2>/dev/null

	___x_cmd_hotkey_co_register_guard_widgets
}

___x_cmd_hotkey_co_toggle_mode() {
	emulate -L zsh

	local prefix="${___X_CMD_HOTKEY_CO_EMOJI:-🤖} "

	if [ "$___X_CMD_HOTKEY_CO_MODE_ACTIVE" = 1 ]; then
		if [ "$BUFFER" != "${BUFFER#"$prefix"}" ]; then
			local plen=${#prefix}
			BUFFER="${BUFFER#$prefix}"
			if [ "$CURSOR" -gt "$plen" ]; then
				CURSOR=$((CURSOR - plen))
			else
				CURSOR=0
			fi
		fi
		___X_CMD_HOTKEY_CO_MODE_ACTIVE=0
		if (( $+functions[___x_cmd_hotkey_co_orig___command_not_found_handler] )); then
			functions[command_not_found_handler]=$functions[___x_cmd_hotkey_co_orig___command_not_found_handler]
		else
			unset -f command_not_found_handler 2>/dev/null
		fi
	else
		BUFFER="${prefix}${BUFFER}"
		CURSOR=$((CURSOR + ${#prefix}))
		___X_CMD_HOTKEY_CO_MODE_ACTIVE=1

		if (( $+functions[command_not_found_handler] )); then
			functions[___x_cmd_hotkey_co_orig___command_not_found_handler]=$functions[command_not_found_handler]
		fi

		command_not_found_handler() {
			emulate -L zsh

			if [ "$___X_CMD_HOTKEY_CO_EXECUTING" = "1" ]; then
				printf "%s\n" "zsh: command not found: $cmd" >&2
				return 127
			fi

			local cmd="$1"
			if [ -z "$cmd" ]; then
				if (( $+functions[___x_cmd_hotkey_co_orig___command_not_found_handler] )); then
					___x_cmd_hotkey_co_orig___command_not_found_handler "$@"
					return $?
				fi
				return 127
			fi

			if command -v "$cmd" >/dev/null 2>&1; then
				if (( $+functions[___x_cmd_hotkey_co_orig___command_not_found_handler] )); then
					___x_cmd_hotkey_co_orig___command_not_found_handler "$@"
					return $?
				fi
				return 127
			fi

			if ! command -v ___x_cmd >/dev/null 2>&1; then
				if (( $+functions[___x_cmd_hotkey_co_orig___command_not_found_handler] )); then
					___x_cmd_hotkey_co_orig___command_not_found_handler "$@"
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
}

___x_cmd_hotkey_co_line_init() {
	emulate -L zsh

	if [ "$___X_CMD_HOTKEY_CO_MODE_ACTIVE" = 1 ]; then
		local prefix="${___X_CMD_HOTKEY_CO_EMOJI:-🤖} "
		BUFFER="${prefix}"
		CURSOR=${#prefix}
	fi
}

___x_cmd_hotkey_co_line_finish() {
	emulate -L zsh

	if [ "$___X_CMD_HOTKEY_CO_MODE_ACTIVE" = 1 ]; then
		local prefix="${___X_CMD_HOTKEY_CO_EMOJI:-🤖} "

		if [ "$BUFFER" != "${BUFFER#"$prefix"}" ]; then
			local plen=${#prefix}
			BUFFER="${BUFFER#$prefix}"
			if [ "$CURSOR" -ge "$plen" ]; then
				CURSOR=$(( CURSOR - plen ))
			fi
		fi
	fi
}

___x_cmd_hotkey_co_line_pre_redraw() {
	emulate -L zsh

	if [ "$___X_CMD_HOTKEY_CO_MODE_ACTIVE" = 1 ]; then
		local prefix="${___X_CMD_HOTKEY_CO_EMOJI:-🤖} "
		if [ "$BUFFER" = "${BUFFER#"$prefix"}" ]; then
			BUFFER="${prefix}${BUFFER}"
			CURSOR=$((CURSOR + ${#prefix}))
		fi
	fi
}

___x_cmd_hotkey_co_register_guard_widgets() {
	local w
	local r

	for w in "backward-delete-char" "backward-kill-word" "vi-backward-delete-char" "vi-backward-kill-word"; do
		if zle -A "$w" ".${w}" 2>/dev/null; then
			r="${w//-/_}"
			zle -A "$w" "___x_cmd_hotkey_co_guard___orig_${r}" 2>/dev/null || true
		fi
		zle -N "$w" ___x_cmd_hotkey_co_guard_backward_action 2>/dev/null
	done
}

___x_cmd_hotkey_co_guard_backward_action() {
	emulate -L zsh

	if [ "$___X_CMD_HOTKEY_CO_MODE_ACTIVE" != 1 ]; then
		___x_cmd_hotkey_co_call_guard_orig
		return $?
	fi

	local prefix="${___X_CMD_HOTKEY_CO_EMOJI:-🤖} "
	local plen=${#prefix}

	if [ "$BUFFER" != "${BUFFER#"$prefix"}" ] && [ "$CURSOR" -le "$plen" ]; then
		zle beep 2>/dev/null
		return $?
	fi

	___x_cmd_hotkey_co_call_guard_orig
}

___x_cmd_hotkey_co_call_guard_orig() {
	emulate -L zsh

	local widget="$WIDGET"
	local replaced="${widget//-/_}"

	if zle -A ".${widget}" "___x_cmd_hotkey_co_guard___orig_${replaced}" 2>/dev/null; then
		zle "___x_cmd_hotkey_co_guard___orig_${replaced}" 2>/dev/null
	else
		zle ".${widget}" 2>/dev/null
	fi
}
