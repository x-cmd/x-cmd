# shellcheck shell=dash


scroll_down_exit_copy_mode_option="@scroll-down-exit-copy-mode"
scroll_in_moused_over_pane_option="@scroll-in-moused-over-pane"
scroll_without_changing_pane_option="@scroll-without-changing-pane"
scroll_speed_num_lines_per_scroll_option="@scroll-speed-num-lines-per-scroll"
emulate_scroll_for_no_mouse_alternate_buffer_option="@emulate-scroll-for-no-mouse-alternate-buffer"

get_repeated_scroll_cmd() {
  local scroll_speed_num_lines_per_scroll;  scroll_speed_num_lines_per_scroll="$(___x_cmd_tmux_config_get_tmux_option "$scroll_speed_num_lines_per_scroll_option" "3")"
  local cmd=""
  local i=1
  while [ "$i" -le "$scroll_speed_num_lines_per_scroll" ]; do
    cmd=$cmd"send-keys $1 ; "
    i=$((i + 1))
  done

  printf "%s\n" "$cmd"
}

better_mouse_mode_main() {
  local scroll_down_to_exit;                              scroll_down_to_exit=$(___x_cmd_tmux_config_get_tmux_option "$scroll_down_exit_copy_mode_option" "on")
  local scroll_in_moused_over_pane;                       scroll_in_moused_over_pane=$(___x_cmd_tmux_config_get_tmux_option "$scroll_in_moused_over_pane_option" "on")
  local scroll_without_changing_pane;                     scroll_without_changing_pane=$(___x_cmd_tmux_config_get_tmux_option "$scroll_without_changing_pane_option" "off")
  local emulate_scroll_for_no_mouse_alternate_buffer;     emulate_scroll_for_no_mouse_alternate_buffer=$(___x_cmd_tmux_config_get_tmux_option "$emulate_scroll_for_no_mouse_alternate_buffer_option" "on")

  local enter_copy_mode_cmd="copy-mode"
  [ "$scroll_down_to_exit" != 'on' ] || enter_copy_mode_cmd="copy-mode -e"

  local select_moused_over_pane_cmd=""
  local check_for_fullscreen_alternate_buffer=""

  [ "$scroll_in_moused_over_pane" != 'on' ] || select_moused_over_pane_cmd="select-pane -t= ;"

  if [ "$scroll_without_changing_pane" = 'on' ]; then
    enter_copy_mode_cmd="$enter_copy_mode_cmd -t="
    select_moused_over_pane_cmd=""
  fi

  [ "$emulate_scroll_for_no_mouse_alternate_buffer" != 'on' ] || check_for_fullscreen_alternate_buffer="#{alternate_on}"

  # Start copy mode when scrolling up and exit when scrolling down to bottom.
  # The "#{mouse_any_flag}" check just sends scrolls to any program running that
  # has mouse support (like vim).
  # NOTE: the successive levels of quoting commands gets a little confusing
  #   here. Tmux uses quoting to denote levels of the if-blocks below. The
  #   pattern used here for consistency is " \" ' \\\" \\\"  ' \" " -- that is,
  #   " for top-level quotes, \" for the next level in, ' for the third level,
  #   and \\\" for the fourth (note that the fourth comes from inside get_repeated_scroll_cmd).

  $___X_CMD_TMUX_BIN bind-key -n WheelUpPane \
    if -Ft= "#{mouse_any_flag}" \
    "send-keys -M" \
    " \
        if -Ft= '$check_for_fullscreen_alternate_buffer' \
          \"$(get_repeated_scroll_cmd "-t= up")\" \
          \" \
            $select_moused_over_pane_cmd \
            if -Ft= '#{pane_in_mode}' \
              '$(get_repeated_scroll_cmd -M)' \
              '$enter_copy_mode_cmd ; $(get_repeated_scroll_cmd -M)' \
          \" \
      "
  # Enable sending scroll-downs to the moused-over-pane.
  # NOTE: the quoting pattern used here and in the above command for
  #   consistency is " \" ' \\\" \\\"  ' \" " -- that is, " for top-level quotes,
  #   \" for the next level in, ' for the third level, and \\\" for the fourth
  #   (note that the fourth comes from inside get_repeated_scroll_cmd).
  $___X_CMD_TMUX_BIN bind-key -n WheelDownPane \
    if -Ft= "#{mouse_any_flag}" \
    "send-keys -M" \
    " \
        if -Ft= \"$check_for_fullscreen_alternate_buffer\" \
          \"$(get_repeated_scroll_cmd "-t= down")\" \
          \"$select_moused_over_pane_cmd $(get_repeated_scroll_cmd -M)\" \
      "

  # For tmux 2.4+ you have to set the mouse wheel options seperately for copy-mode than from root.
  local scroll_speed_num_lines_per_scroll;  scroll_speed_num_lines_per_scroll=$(___x_cmd_tmux_config_get_tmux_option "$scroll_speed_num_lines_per_scroll_option" "3")
  $___X_CMD_TMUX_BIN bind-key -Tcopy-mode     WheelUpPane     send -N"$scroll_speed_num_lines_per_scroll" -X scroll-up
  $___X_CMD_TMUX_BIN bind-key -Tcopy-mode     WheelDownPane   send -N"$scroll_speed_num_lines_per_scroll" -X scroll-down
  $___X_CMD_TMUX_BIN bind-key -Tcopy-mode-vi  WheelUpPane     send -N"$scroll_speed_num_lines_per_scroll" -X scroll-up
  $___X_CMD_TMUX_BIN bind-key -Tcopy-mode-vi  WheelDownPane   send -N"$scroll_speed_num_lines_per_scroll" -X scroll-down
}

better_mouse_mode_main
