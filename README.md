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

Now x-cmd still in alpha version for insdier only. We plan to release our first beta version on June 25th. 
<br>
If you like x-cmd, please give us a star ⭐. 
<br>
Your support is our biggest motivation.

<br>

## Demo

[x theme](https://www.x-cmd.com/basic/theme) - Use command line prompt theme

![x theme demo gif](https://user-images.githubusercontent.com/40693636/220616378-06eb5edc-5baa-45e2-9486-7f32a5496400.gif)

[x zuz](https://www.x-cmd.com/basic/zuz) - Compress or Decompress file

![x zuz demo gif](https://user-images.githubusercontent.com/40693636/218275404-64affeb0-5e77-4b3b-b46e-cb46642d8da9.gif)

[x tldr](https://www.x-cmd.com/basic/tldr) - Collaborative cheatsheets for console commands

![x tldr demo gif](https://user-images.githubusercontent.com/40693636/218275753-8528af6f-fbde-4563-8ec2-cf911a7660e0.gif)


## Introduction

1. Supports one-click execution of hosted scripts in the posixcompatible shells ([bash](http://tiswww.case.edu/php/chet/bashbashtop.html)/[zsh](https://www.zsh.org/)/[dash](https://manpagesdebian.org/bullseye/dash/dash.1.en.html)/[ash](https://github.comash-shell/ash), with more to be supported in the future), even innon-scratch lightweight container images such as [busybox](https:/busybox.net/) and [alpine](https://www.alpinelinux.org/).
2. Supports installation of mainstream programming languageruntimes (currently supports [node](https://nodejs.org/en/),[python](https://www.python.org/), [java](https://www.java.comen/), etc.), allowing users to execute hosted scripts with oneclick on environments with x environment.
3. Enhances the user experience of posix shell with themes, quickpath navigation, and better shell intelligent completion andprompting features to be added in the future.
4. Provides a range of interactive CLI tools ([github](https:/github.com/), [gitee](https://gitee.com/), with more tool modulesto be released in the next six months).
5. Extremely light and fast: the size of the full-featured moduleinstallation package does not exceed 500KB, and the shell loadingtime after initial startup generally does not exceed 100ms.

## module write in pure posix shell

| 模块 | 功能 | 类似项目 |
| --- | --- | --- |
| theme | 设置shell的主题  | [oh-my-zsh](https://ohmyz.sh/) [oh-my-bash](https://ohmybash.nntoan.com/) |
| tldr | 可浏览命令的使用案例  | [tldr客户端工具](https://github.com/tldr-pages/tldr) |
| proxy | 快速配置[apt](https://pkgs.org/download/apt),[pip](https://pypi.org/project/pip/),[npm](https://www.npmjs.com/)等下载源 | 未知 |
| z/uz | 根据后缀实现多种格式的压缩和解压  | 未知 |
| pick | 交互式选择 | [percol](https://github.com/mooz/percol) |
| gh | github交互客户端  | [官方的go版gh](https://cli.github.com/) |
| gt | gitee交互客户端 | ? |
| ws | 项目脚本管理 | ? |
| env | 安装脚本运行/开发环境  | [asdf](https://asdf-vm.com/)/[nvm](https://github.com/nvm-sh/nvm)/[sdkman](https://sdkman.io/)/[pyenv](https://github.com/pyenv/pyenv)/[rbenv](https://github.com/rbenv/rbenv)/... |
| hub | 脚本发布服务 | ? |

## Module empowered by modern command tools

| 模块 | 封装目标 | 功能 |
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