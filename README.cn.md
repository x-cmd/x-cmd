<p align="center">
    <a target="_blank" href="https://cn.x-cmd.com">
        <img src="https://foruda.gitee.com/images/1676141778442772704/6846937e_9641432.png" alt="x-cmd-logo" width="140" hight="140">
    </a>
</p>

<h1 align="center"><a target="_blank" href="https://cn.x-cmd.com">X-CMD</a></h1>

<p align="center">在云上 施展 弹指神通 ～</p>

<p align="center">
  <a target="_blank" href="https://cn.x-cmd.com">
    <img style="display:inline-block;margin:0.2em;" alt="x-cmd-version" src="https://img.shields.io/badge/alpha v0.1.0-107fbc.svg">
  </a>
</p>

<p align="center">
  <a target="_blank" href="https://cn.x-cmd.com">官网</a>
  &nbsp; | &nbsp;
  <a href="https://cn.x-cmd.com/">安装</a>
</p>

现在仍处于内测阶段（v0.1.0 版本）。我们计划在6月25日发布首个公测版本。
<br>
如果你觉得x-cmd不错，请给我们一个 star ⭐ 
<br>
你的支持是我们不断改进的动力 ~


## 先睹为快

[x theme](https://www.x-cmd.com/basic/theme) -  更改使用命令行主题

![x theme demo gif](https://foruda.gitee.com/images/1677067960083339501/19e2472d_9641432.gif "theme.gif")

[x zuz](https://www.x-cmd.com/basic/zuz) - 压缩或解压文件

![x zuz demo gif](https://foruda.gitee.com/images/1676142444494253456/e28beb06_9641432.gif "zuz.gif")

[x tldr](https://www.x-cmd.com/basic/tldr) - 命令行的快捷备忘录

![x tldr demo gif](https://foruda.gitee.com/images/1676142452819542463/2799d158_9641432.gif "tldr.gif")


## 介绍

1. 可在主流posix shell([bash](http://tiswww.case.edu/php/chet/bash/bashtop.html)/[zsh](https://www.zsh.org/)/[dash](https://manpages.debian.org/bullseye/dash/dash.1.en.html)/[ash](https://github.com/ash-shell/ash)，更多将在后续支持)系统环境下(即便在非scratch轻量容器镜像内，如[busybox](https://busybox.net/)，[alpine](https://www.alpinelinux.org/)等镜像)，一键运行托管脚本
2. 可安装主流开发语言运行时（现支持[node](https://nodejs.org/en/)，[python](https://www.python.org/)，[java](https://www.java.com/en/)等等），在此之上，可让用户在装有x环境下的环境上一键运行托管脚本
3. 增强posix shell的用户体验：主题，路径快速跳转，后面会加入更好的shell智能补全和提示功能
4. 提供一系列的交互式cli工具（[github](https://github.com/), [gitee](https://gitee.com/)，更多的工具模块将在最近半年发布）
5. 极轻极快: 包括全功能模块安装包体积不超过500KB，首启后shell的加载时间一般不超过100ms


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


