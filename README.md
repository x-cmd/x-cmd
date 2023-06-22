<p align="center">
    <a target="_blank" href="https://x-cmd.com/">
        <img src="https://user-images.githubusercontent.com/40693636/218274071-92a26d84-0550-4b90-a0ba-7d54118c56e1.png" alt="x-cmd-logo" width="140" hight="140">
    </a>
</p>

<h1 align="center"><a target="_blank" href="https://x-cmd.com/">X-CMD</a></h1>

<p align="center">Let's forge your Excalibur in Cloud.</p>

<p align="center">
  <a target="_blank" href="https://x-cmd.com/">
    <img style="display:inline-block;margin:0.2em;" alt="x-cmd-version" src="https://img.shields.io/badge/alpha v0.1.0-107fbc.svg">
  </a>
</p>

<p align="center">
  <a target="_blank" href="https://x-cmd.com/">Website</a>
  &nbsp; | &nbsp;
  <a href="https://x-cmd.com/">Install</a>
</p>

<p align="center">
Now x-cmd still in alpha version for insdier only. We plan to release our first beta version on June 25th.
<br>
If you like x-cmd, please give us a star ⭐.
<br>
Your support is our biggest motivation.
</p>

![x theme demo gif](https://user-images.githubusercontent.com/40693636/220616378-06eb5edc-5baa-45e2-9486-7f32a5496400.gif)


## Introduction

1. Supports one-click execution of hosted scripts in the posixcompatible shells ([bash](http://tiswww.case.edu/php/chet/bashbashtop.html)/[zsh](https://www.zsh.org/)/[dash](https://manpagesdebian.org/bullseye/dash/dash.1.en.html)/[ash](https://github.comash-shell/ash), with more to be supported in the future), even innon-scratch lightweight container images such as [busybox](https:/busybox.net/) and [alpine](https://www.alpinelinux.org/).
2. Supports installation of programming language runtimes (currently supports [node](https://nodejs.org/en/),[python](https://www.python.org/), [java](https://www.java.comen/), etc.), allowing users to execute hosted scripts with oneclick on environments with x environment.
3. Enhances the user experience of posix shell with themes, quickpath navigation, and better shell intelligent completion and prompting features to be added in the future.
4. Provides a range of interactive CLI tools ([github](https:/github.com/), [gitee](https://gitee.com/), with more tool modules to be released in the next six months).
5. Extremely light and fast: the size of the full-featured moduleinstallation package does not exceed 500KB, and the shell loadingtime after initial startup generally does not exceed 100ms.

## Module write in pure posix shell

| Module | Function | Similar items |
| --- | --- | --- |
| theme | Set the theme of the shell  | [oh-my-zsh](https://ohmyz.sh/) /[oh-my-bash](https://ohmybash.nntoan.com/) |
| tldr | Use cases for browsable commands  | [tldr client tool](https://github.com/tldr-pages/tldr) |
| proxy |Quickly configure download sources such as [apt](https://pkgs.org/download/apt),[pip](https://pypi.org/project/pip/),[npm](https://www.npmjs.com/) etc. | unknown |
| z/uz | Compression and decompression of various formats according to the suffix  | unknown |
| pick | interactive selection | [percol](https://github.com/mooz/percol) |
| gh | github interactive client  | [Official Github CLI for Go](https://cli.github.com/) |
| gt | gitee interactive client | ? |
| ws | Project script management | ? |
| env | Setup Script Runtime/Development Environment  | [asdf](https://asdf-vm.com/)/[nvm](https://github.com/nvm-sh/nvm)/[sdkman](https://sdkman.io/)/[pyenv](https://github.com/pyenv/pyenv)/[rbenv](https://github.com/rbenv/rbenv)/... |
| hub | Script Publishing Service | ? |

## Module empowered by modern command tools

| Module | Package target | Function |
| -- | -- | -- |
| ssl/openssl | [openssl](https://www.openssl.org/) | Secure cryptographic |
| p7zip | [7zip](https://www.7-zip.org) | Compression and decompression |
| ff | [ffmpeg](https://ffmpeg.org/) | Audio and video  |
| pandoc | [pandoc](https://pandoc.org/) | Document format conversion |
| nmap | [nmap](https://nmap.org/) | Security scanning |
| fd | [fd](https://github.com/sharkdp/fd) | Efficient replacement for find|
| grep | [ag](https://github.com/ggreer/the_silver_searcher) | Efficient replacement for grep  |
| smartmontools | [smartmontools](https://www.smartmontools.org/) | Hard drive monitoring tool   |
| bat | [bat](https://github.com/sharkdp/bat) |Rust implementation of cat|
| jq/yq | [jq](https://stedolan.github.io/jq/)/[yq](https://github.com/mikefarah/yq) | [json](https://www.json.org/json-en.html)/[yml](https://yaml.org/) |