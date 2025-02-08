# shellcheck shell=dash

___x_cmd___hook_zsh_plugin_boot(){
    [ -n "$ZSH_VERSION" ] ||{
        # pkg:error "This plugin is only for ZSH"
        return 0
    }
    local zsh_plugins
    local plugin
    zsh_plugins=("${(@s/,/)ZSH_PLUGIN:-"zsh-async,zsh-syntax-highlighting,zsh-autosuggestions,zsh-config"}")

    for plugin in "${zsh_plugins[@]}"; do
        if ! . "$___X_CMD_PKG___META_TGT/$name/$plugin/$plugin.zsh"; then
            printf "\033[31m%s\n\033[36m%s\033[0m\n" "Failed to load plugin: $plugin" "x env try zsh-plugin"
            return 1
        fi
    done
}

___x_cmd___hook_zsh_plugin_boot
