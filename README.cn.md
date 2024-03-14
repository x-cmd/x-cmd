<p align="center">
    <a target="_blank" href="https://cn.x-cmd.com">
        <img src="https://foruda.gitee.com/images/1676141778442772704/6846937e_9641432.png" alt="x-cmd-logo" width="140" hight="140">
    </a>
</p>

<h1 align="center"><a target="_blank" href="https://cn.x-cmd.com">X-CMD</a></h1>

<p align="center">在云上 施展 弹指神通 ～</p>

<p align="center">
  <a target="_blank" href="https://cn.x-cmd.com">
    <img style="display:inline-block;margin:0.2em;" alt="x-cmd-version" src="https://img.shields.io/github/v/release/x-cmd/x-cmd?label=beta&labelColor=107fbc">
  </a>
</p>

<p align="center">
  <a target="_blank" href="https://cn.x-cmd.com">官网</a>
  &nbsp; | &nbsp;
  <a href="https://cn.x-cmd.com/">安装</a>
</p>

<p align="center">
现在处于 beta 阶段（v0.2.12 版本），请勿用于生产环境。我们计划在未来三个月以每个月3个版本的速度往前迭代。
<br>
如果你觉得 x-cmd 不错，请给我们一个 star ⭐
<br>
你的支持是我们不断改进的动力 ~
</p>

![x theme demo gif](https://foruda.gitee.com/images/1697770832734408357/545a3160_11092596.gif "theme.gif")


## [介绍](https://x-cmd.com)

1. 可在主流 posix shell ( **ash/dash/bash/zsh**，更多将在后续支持) 系统环境下(即便在非 scratch 轻量容器镜像内，如 busybox 和 alpine 等镜像)，一键运行托管脚本
2. 可安装主流开发语言运行时（现支持 **node, python, java** 等等），在此之上，可让用户在装有x环境下的环境上一键运行托管脚本
3. 增强 posix shell 的用户体验：主题，路径快速跳转，后面会加入更好的shell智能补全和提示功能
4. 提供一系列的交互式 cli 工具（ gh for github, gt for gitee ，更多的工具模块将在最近半年发布）
5. 极轻极快: 包括全功能模块安装包体积 1.1MB，首启后 shell 的加载时间一般不超过100ms

现有 **超过 100** 个[模块](https://x-cmd.com/mod)，**接近 500 个**的[包](https://x-cmd.com/pkg)，以及 **超过 1000 条** [install](https://www.x-cmd.com/install/) receipe ~

## [模块](https://x-cmd.com/mod/)

| 模块 | 功能 | 类似项目 |
| --- | --- | --- |
| [env](https://cn.x-cmd.com/mod/env) | 安装脚本运行/开发环境  | [asdf](https://asdf-vm.com/)/[nvm](https://github.com/nvm-sh/nvm)/[sdkman](https://sdkman.io/)/[pyenv](https://github.com/pyenv/pyenv)/[rbenv](https://github.com/rbenv/rbenv)/... |
| [theme](https://cn.x-cmd.com/mod/theme) | 设置shell的主题  | [oh-my-zsh](https://ohmyz.sh/) [oh-my-bash](https://ohmybash.nntoan.com/) |
| [tldr](https://cn.x-cmd.com/mod/tldr) | 可浏览命令的使用案例  | [tldr客户端工具](https://github.com/tldr-pages/tldr) |
| [proxy](https://cn.x-cmd.com/mod/proxy) | 快速配置[apt](https://pkgs.org/download/apt),[pip](https://pypi.org/project/pip/),[npm](https://www.npmjs.com/)等下载源 | 未知 |
| [gh](https://cn.x-cmd.com/mod/gh) | github交互客户端  | [官方的go版gh](https://cli.github.com/) |
| [z/uz](https://cn.x-cmd.com/mod/zuz) | 根据后缀实现多种格式的压缩和解压  | 未知 |
| [pick](https://cn.x-cmd.com/mod/pick) | 交互式选择 | [fzf]() [percol](https://github.com/mooz/percol) |
| [gt](https://cn.x-cmd.com/mod/gt) | gitee交互客户端 | ? |
| [ws](https://cn.x-cmd.com/mod/ws) | 项目脚本管理 | ? |
| [hub](https://cn.x-cmd.com/mod/hub) | 脚本发布服务 | ? |

## [包](https://x-cmd.com/pkg/)

| 包 | 官网 | 功能 |
| -- | -- | -- |
| [jq](https://cn.x-cmd.com/pkg/jq)/[yq](https://cn.x-cmd.com/pkg/yq) | [jq](https://stedolan.github.io/jq/)/[yq](https://github.com/mikefarah/yq) | [json](https://www.json.org/json-en.html)/[yml](https://yaml.org/)处理 |
| [p7zip](https://cn.x-cmd.com/pkg/7za) | [7zip](https://www.7-zip.org) | 加解压工具 |
| [ffmpeg](https://cn.x-cmd.com/pkg/ffmpeg) | [ffmpeg](https://ffmpeg.org/) | 音视频工具工具 |
| [openssl](https://cn.x-cmd.com/pkg/openssl) | [openssl](https://www.openssl.org/) | 安全密码学工具 |
| [fd](https://cn.x-cmd.com/pkg/fd) | [fd](https://github.com/sharkdp/fd) | find的高效替代 |
| [rg](https://cn.x-cmd.com/pkg/rg) | [rg](https://github.com/BurntSushi/ripgrep) | grep的高效替代 |
| [sd](https://cn.x-cmd.com/pkg/sd) | [rg](https://github.com/BurntSushi/ripgrep) | 类sed，但更易上手 |
| [bat](https://cn.x-cmd.com/pkg/bat) | [bat](https://github.com/sharkdp/bat) | cat的rust实现 |
| [nmap](https://cn.x-cmd.com/pkg/nmap) | [nmap](https://nmap.org/) | 安全扫描工具 |
| [pandoc](https://cn.x-cmd.com/pkg/pandoc) | [pandoc](https://pandoc.org/) | 文档格式转换工具 |
| [smartmontools](https://cn.x-cmd.com/pkg/smartctl) | [smartmontools](https://www.smartmontools.org/) | 硬盘监控工具 |
