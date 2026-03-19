# shellcheck shell=dash

___x_cmd_tmux_config_get_tmux_version() {
  $___X_CMD_TMUX_BIN -V | cut -d " " -f 2
}

___x_cmd_tmux_config_get_tmux_option() {
  local option_value;   option_value="$($___X_CMD_TMUX_BIN show-option -gqv "${1:?Please proivide opttion name}")"
  printf "%s\n" "${option_value:-$2}"
}


# ___x_cmd_tmux_set_color(){
#     : bg : color222 color111 color150 color140
#     $___X_CMD_TMUX_BIN set status-bg "$1"
#     # x $___X_CMD_TMUX_BIN set status-fg "$2"
# }
