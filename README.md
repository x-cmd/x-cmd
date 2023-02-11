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
  <a target="_blank" href="https://x-cmd.com/">Official Website</a>
  &nbsp; | &nbsp;
  <a href="#install">Installation Guide</a>
  <br>
  <a target="_blank" href="https://x-cmd.com/zh/">简体中文文档</a>
</p>

Now x-cmd still in alpha version for insdier only. We will be ready in the next three months. If you like x-cmd, please give us a star ⭐. Your support is our biggest motivation.

<br>

## Demo

[x theme](https://www.x-cmd.com/basic/theme) - Use command line prompt theme

![x theme demo gif](https://user-images.githubusercontent.com/40693636/218275249-f600e2a5-32e1-4247-9ec3-f6fc6705ded9.gif)

[x zuz](https://www.x-cmd.com/basic/zuz) - Compress or Decompress file

![x zuz demo gif](https://user-images.githubusercontent.com/40693636/218275404-64affeb0-5e77-4b3b-b46e-cb46642d8da9.gif)

[x tldr](https://www.x-cmd.com/basic/tldr) - Collaborative cheatsheets for console commands

![x tldr demo gif](https://user-images.githubusercontent.com/40693636/218275753-8528af6f-fbde-4563-8ec2-cf911a7660e0.gif)

## Install

Install using [curl](https://curl.se/):

```bash
eval "$(curl https://get.x-cmd.com)"
```

Install using [wget](https://www.gnu.org/software/wget/)(For example: in the alpine base container image there is only wget ready.):

```bash
eval "$(wget -O- https://get.x-cmd.com)"
```

容器注入法安装(例如: debian/ubuntu容器无wget和curl的情况): (待实现)

```bash
x setup <container-name>
```

## 应用模块列表

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

## 封装模块列表

| 模块 | 封装目标 | 功能 |
| -- | -- | -- |
| ssl/openssl | [openssl](https://www.openssl.org/) | 安全密码学工具 |
| p7zip | [7zip](https://www.7-zip.org) | 加解压工具 |
| ff | [ffmpeg](https://ffmpeg.org/) | 音视频工具工具 |
| pandoc | [pandoc](https://pandoc.org/) | 文档格式转换工具 |
| nmap | [nmap](https://nmap.org/) | 安全扫描工具 |
| fd | [fd](https://github.com/sharkdp/fd) | find的高效替代 |
| grep | [ag](https://github.com/ggreer/the_silver_searcher) | grep的高效替代 |
| smartmontools | [smartmontools](https://www.smartmontools.org/) | 硬盘监控工具 |
| bat | [bat](https://github.com/sharkdp/bat) | cat的rust实现 |
| jq/yq | [jq](https://stedolan.github.io/jq/)/[yq](https://github.com/mikefarah/yq) | [json](https://www.json.org/json-en.html)/[yml](https://yaml.org/)处理 |


## 介绍

1. 可在主流posix shell([bash](http://tiswww.case.edu/php/chet/bash/bashtop.html)/[zsh](https://www.zsh.org/)/[dash](https://manpages.debian.org/bullseye/dash/dash.1.en.html)/[ash](https://github.com/ash-shell/ash)，更多将在后续支持)系统环境下(即便在非scratch轻量容器镜像内，如[busybox](https://busybox.net/)，[alpine](https://www.alpinelinux.org/)等镜像)，一键运行托管脚本
2. 可安装主流开发语言运行时（现支持[node](https://nodejs.org/en/)，[python](https://www.python.org/)，[java](https://www.java.com/en/)等等），在此之上，可让用户在装有x环境下的环境上一键运行托管脚本
3. 增强posix shell的用户体验：主题，路径快速跳转，后面会加入更好的shell智能补全和提示功能
4. 提供一系列的交互式cli工具（[github](https://github.com/), [gitee](https://gitee.com/)，更多的工具模块将在最近半年发布）
5. 极轻极快: 包括全功能模块安装包体积不超过500KB，首启后shell的加载时间一般不超过100ms

