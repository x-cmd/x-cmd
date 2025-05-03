English | <a href="README.cn.md">中文</a> | <a href="https://github.com/x-cmd/x-cmd/tree/main/mod">Source Code</a> ⭐

<p align="center">
    <a target="_blank" href="https://x-cmd.com/">
        <img src="https://user-images.githubusercontent.com/40693636/218274071-92a26d84-0550-4b90-a0ba-7d54118c56e1.png" alt="x-cmd-logo" width="140" hight="140">
    </a>
</p>

<h1 align="center"><a target="_blank" href="https://x-cmd.com/">X-CMD</a></h1>

<p align="center">Your AI-Powered Excalibur in Cloud.</p>

<p align="center">
  <a target="_blank" href="https://x-cmd.com/v">
    <img style="display:inline-block;margin:0.2em;" alt="x-cmd-version" src="https://img.shields.io/github/v/release/x-cmd/x-cmd?label=latest&labelColor=107fbc&color=107fbc">
  </a>
</p>

<p align="center">
  <a target="_blank" href="https://x-cmd.com/">Website</a>
  &nbsp; | &nbsp;
  <a href="https://x-cmd.com/">Install</a>
</p>

<p align="center">
For <bold>source code</bold>, please visit <a href="https://github.com/x-cmd/x-cmd/tree/main/mod">main</a> branch.
<br>
<a href="https://github.com/x-cmd/x-cmd/tree/X/README.md">X</a> branch is for demo and action ⭐
</p>

## [x ping](https://x-cmd.com/mod/ping) - Visual Enhancement of the Ping Command

![x ping](https://github.com/user-attachments/assets/1edf908f-2b90-407c-bb8b-dec461790f34)

## [x man](https://x-cmd.com/mod/man) - Preview Enhancement based on FZF

![man en](https://github.com/user-attachments/assets/3eefcc80-592f-4724-b910-1f0fe611d451)

## [x gemini](https://www.x-cmd.com/mod/gemini) - Chat with Gemini AI models

![gemini en](https://github.com/user-attachments/assets/f09fe096-60a6-4c90-8ab1-cd47d13d4e73)

## [x env](https://www.x-cmd.com/pkg/) - Environment Management

![env en](https://github.com/user-attachments/assets/c5a441fa-9a1a-4d2b-bb04-88cd528820e6)

## [x jq](https://x-cmd.com/mod/jq)/[x yq](https://x-cmd.com/mod/yq) - Quickly test JQ expressions

![jq_r](https://github.com/user-attachments/assets/87ea8277-b6d0-4140-ac48-f21e852c4714)

## [x osv](https://x-cmd.com/mod/osv)

![x osv demo gif](https://github.com/x-cmd/x-cmd/assets/40693636/f7c8c503-3d77-4939-8932-f2c03ed8f263)

## [x theme](https://x-cmd.com/theme) - Terminal Themes for  Posix Shells

![x theme demo gif](https://user-images.githubusercontent.com/112856271/276805596-08998349-eda3-4107-93ff-61daade67032.gif)

## [Introduction](https://x-cmd.com)

1. Supports one-click execution of hosted scripts in the posixcompatible shells (**ash/bash/dash/zsh**, with more to be supported in the future), even innon-scratch lightweight container images such as busybox and alpine.
2. Supports installation of programming language runtimes (currently supports **node, python, java**, etc.), allowing users to execute hosted scripts with oneclick on environments with x environment.
3. Enhances the user experience of posix shell with themes, quickpath navigation, and better shell intelligent completion and prompting features to be added in the future.
4. Provides a range of interactive CLI tools (gh for github, gt for gitee, with more tool modules to be released in the next six months).
5. Extremely light and fast: the size of the full-featured moduleinstallation package does not exceed 1.1MB, and the shell loadingtime after initial startup generally does not exceed 100ms.

Now there are more than **210** [modules](https://x-cmd.com/mod), **more than 520** [packages](https://x-cmd.com/pkg), and **more than 1200** [install](https://www.x-cmd.com/install/) receipes ~

## [Module](https://x-cmd.com/mod/)

| Module | Function | Similar items |
| --- | --- | --- |
| [theme](https://x-cmd.com/mod/theme) | Set the theme of the shell  | [oh-my-zsh](https://ohmyz.sh/) /[oh-my-bash](https://ohmybash.nntoan.com/) |
| [tldr](https://x-cmd.com/mod/tldr) | Use cases for browsable commands  | [tldr client tool](https://github.com/tldr-pages/tldr) |
| [proxy](https://x-cmd.com/mod/proxy) |Quickly configure download sources such as [apt](https://pkgs.org/download/apt),[pip](https://pypi.org/project/pip/),[npm](https://www.npmjs.com/) etc. | unknown |
| [z/uz](https://x-cmd.com/mod/zuz) | Compression and decompression of various formats according to the suffix  | unknown |
| [pick](https://x-cmd.com/mod/pick) | interactive selection | [percol](https://github.com/mooz/percol) |
| [gh](https://x-cmd.com/mod/gh) | github interactive client  | [Official Github CLI for Go](https://cli.github.com/) |
| [gt](https://x-cmd.com/mod/gt) | gitee interactive client | ? |
| [ws](https://x-cmd.com/mod/ws) | Project script management | ? |
| [env](https://x-cmd.com/mod/env) | Setup Script Runtime/Development Environment  | [asdf](https://asdf-vm.com/)/[nvm](https://github.com/nvm-sh/nvm)/[sdkman](https://sdkman.io/)/[pyenv](https://github.com/pyenv/pyenv)/[rbenv](https://github.com/rbenv/rbenv)/... |
| [hub](https://x-cmd.com/mod/hub) | Script Publishing Service | ? |

## [Package](https://x-cmd.com/pkg/)

| Package | Official Site | Function |
| -- | -- | -- |
| [jq](https://x-cmd.com/pkg/jq)/[yq](https://x-cmd.com/pkg/yq) | [jq](https://stedolan.github.io/jq/)/[yq](https://github.com/mikefarah/yq) | [json](https://www.json.org/json-en.html)/[yml](https://yaml.org/) |
| [p7zip](https://x-cmd.com/pkg/7za) | [7zip](https://www.7-zip.org) | Compression and decompression |
| [ffmpeg](https://x-cmd.com/pkg/ffmpeg) | [ffmpeg](https://ffmpeg.org/) | Audio and video  |
| [openssl](https://x-cmd.com/pkg/openssl) | [openssl](https://www.openssl.org/) | Secure cryptographic |
| [fd](https://x-cmd.com/pkg/fd) | [fd](https://github.com/sharkdp/fd) | Efficient replacement for find|
| [rg](https://x-cmd.com/pkg/rg) | [rg](https://github.com/BurntSushi/ripgrep) | Efficient replacement for grep|
| [sd](https://x-cmd.com/pkg/sd) | [sd](https://github.com/chmln/sd) | Like sed, but more easy to use |
| [bat](https://x-cmd.com/pkg/bat) | [bat](https://github.com/sharkdp/bat) |Rust implementation of cat|
| [nmap](https://x-cmd.com/pkg/nmap) | [nmap](https://nmap.org/) | Security scanning |
| [pandoc](https://x-cmd.com/pkg/pandoc) | [pandoc](https://pandoc.org/) | Document format conversion |
| [smartmontools](https://x-cmd.com/pkg/smartctl) | [smartmontools](https://www.smartmontools.org/) | Hard drive monitoring tool   |


## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=x-cmd/x-cmd&type=Date)](https://star-history.com/#x-cmd/x-cmd&Date)

