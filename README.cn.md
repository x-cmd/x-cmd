<p align="center">
    <a target="_blank" href="https://cn.x-cmd.com">
        <img src="https://foruda.gitee.com/images/1676141778442772704/6846937e_9641432.png" alt="x-cmd-logo" width="140" hight="140">
    </a>
</p>

<h1 align="center"><a target="_blank" href="https://cn.x-cmd.com">X-CMD</a></h1>

<p align="center">在云上 施展 弹指神通 ～</p>

<p align="center">
  <a target="_blank" href="https://cn.x-cmd.com/v">
    <img style="display:inline-block;margin:0.2em;" alt="x-cmd-version" src="https://img.shields.io/github/v/release/x-cmd/x-cmd?label=latest&labelColor=107fbc">
  </a>
</p>

<p align="center">
  <a target="_blank" href="https://cn.x-cmd.com">官网</a>
  &nbsp; | &nbsp;
  <a href="https://cn.x-cmd.com/">安装</a>
</p>

<p align="center">
查看 <bold>源码</bold> 请移步至 <a href="https://github.com/x-cmd/x-cmd/tree/main/mod">main</a> 分支
<br>
<a href="https://github.com/x-cmd/x-cmd/tree/X/README.cn.md">X</a> 分支 仅用于 演示及构建 ⭐
</p>

<table align="center">
    <tr>
        <td align="center" width="300px">
            <b>微信公众号：oh my x</b>
            <p>
            扫码关注官方微信公众号获取开源软件和 x-cmd 的最新用法与独家资讯
            </p>
        </td>
        <td align="center" >
            <img align="center" src="https://foruda.gitee.com/images/1715696069230260264/d8037bf6_9641432.png" alt="公众号二维码，微信搜索：oh my x" height="140">
        </td>
    </tr>
</table>

## [x ping](https://x-cmd.com/ping) - ping 命令增强

![x ping](https://foruda.gitee.com/images/1730451947678480208/ad63805f_8841942.gif "ping.gif")

## [x man](https://x-cmd.com/mod/man) - 基于 fzf 的 预览 增强

![man.cn.gif](https://foruda.gitee.com/images/1722606367684957086/3e06c8f8_8841942.gif "man.cn.gif")

## [x gemini](https://cn.x-cmd.com/mod/gemini) - 使用 Gemini AI 模型

![gemini.cn.gif](https://foruda.gitee.com/images/1724991830376126475/c04d94fb_8841942.gif "gemini.cn.gif")

## [x env](https://cn.x-cmd.com/pkg/) - 环境管理管理

![env.cn.gif](https://foruda.gitee.com/images/1724991931565701591/fa35de65_8841942.gif "env.cn.gif")

## [x jq](https://x-cmd.com/mod/jq)/[x yq](https://x-cmd.com/mod/yq) - 快速测试 JQ 表达式

![jq_r](https://foruda.gitee.com/images/1722588625707099785/131a0613_8841942.gif "jq_r.gif")

## [x osv](https://x-cmd.com/mod/osv)

![x osv demo gif](https://foruda.gitee.com/images/1718078629588146457/5d067d31_9641432.gif)

## [x theme](https://x-cmd.com/theme) - 兼容多种 posix shell 的主题美化

![x theme demo gif](https://foruda.gitee.com/images/1697770832734408357/545a3160_11092596.gif "theme.gif")

## [介绍](https://x-cmd.com)

1. 可在主流 posix shell ( **ash/dash/bash/zsh**，更多将在后续支持) 系统环境下(即便在非 scratch 轻量容器镜像内，如 busybox 和 alpine 等镜像)，一键运行托管脚本
2. 可安装主流开发语言运行时（现支持 **node, python, java** 等等），在此之上，可让用户在装有x环境下的环境上一键运行托管脚本
3. 增强 posix shell 的用户体验：主题，路径快速跳转，后面会加入更好的shell智能补全和提示功能
4. 提供一系列的交互式 cli 工具（ gh for github, gt for gitee ，更多的工具模块将在最近半年发布）
5. 极轻极快: 包括全功能模块安装包体积 1.1MB，首启后 shell 的加载时间一般不超过100ms

现有 **超过 210** 个[模块](https://x-cmd.com/mod)，**超过 520 个**的[包](https://x-cmd.com/pkg)，以及 **超过 1200 条** [install](https://www.x-cmd.com/install/) 指南 ~

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
| [sd](https://cn.x-cmd.com/pkg/sd) | [sd](https://github.com/chmln/sd) | 类sed，但更易上手 |
| [bat](https://cn.x-cmd.com/pkg/bat) | [bat](https://github.com/sharkdp/bat) | cat的rust实现 |
| [nmap](https://cn.x-cmd.com/pkg/nmap) | [nmap](https://nmap.org/) | 安全扫描工具 |
| [pandoc](https://cn.x-cmd.com/pkg/pandoc) | [pandoc](https://pandoc.org/) | 文档格式转换工具 |
| [smartmontools](https://cn.x-cmd.com/pkg/smartctl) | [smartmontools](https://www.smartmontools.org/) | 硬盘监控工具 |


## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=x-cmd/x-cmd&type=Date)](https://star-history.com/#x-cmd/x-cmd&Date)

