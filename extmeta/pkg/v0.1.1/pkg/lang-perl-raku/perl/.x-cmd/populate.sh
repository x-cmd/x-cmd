# shellcheck shell=dash

. "$___X_CMD_PKG_METADATA_PATH/.x-cmd/gen_shim_file.sh"


___x_cmd_pkg_perl_populate(){
    if [ "$___X_CMD_PKG___META_OS" = "win" ]; then
        ___x_cmd_pkg_shim_gen --mode adaptive --code bat --var "PERL5LIB=$___X_CMD_PKG___META_TGT/lib" --bin_dir perl/bin --bin_file perl.exe cpan cpanm  || return
        ___x_cmd_pkg_shim_gen --mode adaptive --code sh  --var "PERL5LIB=$___X_CMD_PKG___META_TGT/lib" --bin_dir perl/bin --bin_file perl.exe cpan cpanm || return
    else
        ___x_cmd_pkg_shim_gen --mode adaptive --code sh --var "PERL5LIB=$___X_CMD_PKG___META_TGT/lib" --bin_dir bin --bin_file perl cpan cpanm  || return
    fi

}
___x_cmd_pkg_perl_populate

