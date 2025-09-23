<a href="README.md">English</a> | 中文 | <a href="https://github.com/x-cmd/x-cmd/tree/main/mod">源码</a> ⭐ <a target="_blank" href="https://cn.x-cmd.com/v"><img align="right"  alt="x-cmd-version" src="https://img.shields.io/github/v/release/x-cmd/x-cmd?label=latest&labelColor=107fbc&color=107fbc"></a>

<p align="center">
    <a target="_blank" href="https://cn.x-cmd.com/">
        <img src="https://user-images.githubusercontent.com/40693636/218274071-92a26d84-0550-4b90-a0ba-7d54118c56e1.png" alt="x-cmd-logo" width="140">
    </a>
</p>

<h1 align="center"><a href="https://cn.x-cmd.com/">X-CMD</a></h1>

<p align="center">
  <b>在云上施展弹指神通 ~</b>
  <br>
  <a href="https://cn.x-cmd.com/">https://x-cmd.com</a>
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
            <img align="center" src="https://foruda.gitee.com/images/1715696069230260264/d8037bf6_9641432.png" alt="公众号二维码，微信搜索：oh my x" width="140">
        </td>
    </tr>
</table>

## [介绍](https://cn.x-cmd.com)

X-CMD（读作 "X Command"）是一个小巧且功能强大的命令行工具集，能提供 <ins>100</ins> 多种针对不同应用场景的功能模块和一个包管理器，支持下载安装 <ins>500+</ins> 个第三方开源软件工具。


- ⚡ **一键启用 1000+ CLI 工具**: 按需下载，像启动 App 一样启动命令行工具。
- 🧠 **AI 加持**: AI 代理, AI 对话, AI 任务, AI 生成 ... 一行命令即刻拥有 AI copilot。
- 🧩 **环境管理**: Node, Python, Java, Go … 等开发环境，即装即用。
- 🛡️ **安全沙箱**: 提供系统权限控制沙箱和基于 Docker 的隔离沙箱 — 在安全空间中放心运行工具。
- 🎨 **终端美化**: 内置终端主题与主题色切换，字体安装器，导航切换和原生的命令补全 — 美观又高效。
- ∞ **一致化设计 & 交互友好**: 统一的命令风格，直观的 TUI 交互，丝滑的流程控制，轻松的终端体验。
- 🗃️ **HUB**: 随时随地运行自托管脚本，即使在 Alpine / Busybox 等极简容器镜像。
- 🪶 **极致轻量化**: 核心包体积 ~ 1.1 MB, 加载时间控制 ~ 100 ms.

[![x-cmd-banner](https://cdn.jsdelivr.net/gh/Zhengqbbb/Zhengqbbb@v1.2.2/x-cmd/x-cmd-banner.png)](https://cn.x-cmd.com)

<pre align="center">
查看源码请移步至 <a href="https://github.com/x-cmd/x-cmd/tree/main/mod">main</a> 分支
<a href="https://github.com/x-cmd/x-cmd/tree/X/README.md">X</a> 分支仅用于演示及构建 ⭐
</pre>

## [安装](https://cn.x-cmd.com/start/)

在常用 shell 中运行[官方安装脚本](https://github.com/x-cmd/get/blob/main/index.html)

- 使用 `curl` 命令安装:
  ```sh
  eval "$(curl https://get.x-cmd.com)"
  ```
- 使用 `wget` 命令安装:
  ```sh
  eval "$(wget -O- https://get.x-cmd.com)"
  ```

<table>
<tbody>
<tr>
<td width="1000px">

**安装指南 - 系统**:

[🐧 Linux and macOS 🍎](https://cn.x-cmd.com/start/linux) &nbsp; | &nbsp; [🟦 Windows](https://cn.x-cmd.com/start/windows) &nbsp; | &nbsp; [🔴 BSD](https://cn.x-cmd.com/start/bsd)

**安装指南 - 非 POSIX Shell**:

[fish](https://cn.x-cmd.com/start/fish) &nbsp; | &nbsp; [Nushell](https://cn.x-cmd.com/start/nushell) &nbsp; | &nbsp; [Elvish](https://cn.x-cmd.com/start/elvish) &nbsp; | &nbsp; [Xonsh](https://cn.x-cmd.com/start/xonsh) &nbsp; | &nbsp; [tcsh](https://cn.x-cmd.com/start/tcsh) &nbsp; | &nbsp; [PowerShell](https://cn.x-cmd.com/start/powershell)

**安装指南 - 包管理器**:

[brew](https://cn.x-cmd.com/start/#homebrew) &nbsp; | &nbsp; [aur](https://cn.x-cmd.com/start/#homebrew) &nbsp; | &nbsp; [apt](https://cn.x-cmd.com/start/#apt) &nbsp; | &nbsp; [apk](https://cn.x-cmd.com/start/#apk) &nbsp; | &nbsp; [pacman](https://cn.x-cmd.com/start/#pacman) &nbsp; | &nbsp; [dnf](https://cn.x-cmd.com/start/#dnf)

</td>
</tr>
</tbody>
</table>

## [Synopsis](https://cn.x-cmd.com/start/design)

<p align="center">
<a href="https://cn.x-cmd.com/start/design">
<img align="center" width="640" alt="Image" src="https://cdn.jsdelivr.net/gh/Zhengqbbb/Zhengqbbb@v1.2.2/x-cmd/x-cmd-synopsis.png" />
</a>
</p>

## [模块](https://cn.x-cmd.com/mod/)

X-CMD 提供的功能模块，通过 `x <mod>` 的方式调用。
<br>
更多介绍请查看 [mod/get-started](https://cn.x-cmd.com/mod/get-started)

<table>
<tr>
<td width="500px"> 🤖 Agent </td>
<td width="500px"> 🧠 AI </td>
</tr>
<tr>
<td width="500px">

```sh
x openai
x gemini
x deepseek
...
```

</td>
<td width="500px">

```sh
x claude
x codex
x crush
...
```

</td>
</tr>

<tr>
<td width="500px"> 🖥️ 系统管理. </td>
<td width="500px"> 📁 文件 & 存储 </td>
</tr>
<tr>
<td width="500px">

```sh
x mac
x cd
x top
x ps
...
```

</td>
<td width="500px">

```sh
x zuz
x ls
x path
x df
...
```

</td>
</tr>

<tr>
<td width="500px"> 🫙 Git </td>
<td width="500px"> 📦 包管理 </td>
</tr>
<tr>
<td width="500px">

```sh
x gh
x gt
x gl
x cb
...
```

</td>
<td width="500px">

```sh
x env
x install
x brew
x apt
...
```

</td>
</tr>

<tr>
<td colspan="2">

[更多模块...](https://cn.x-cmd.com/mod/)

</td>
</tr>
</table>
<br>

## [包](https://cn.x-cmd.com/pkg/)

X-CMD 收录的工具软件包，由 [env](https://cn.x-cmd.com/mod/env) 模块进行驱动管理。

<table>
  <tr>
    <th width="500px">描述</th>
    <th width="500px">命令</th>
  </tr>
  <tr>
    <td>交互式查看可安装的 package</td>
    <td><a href="https://cn.x-cmd.com/mod/env">x env</a></td>
  </tr>
  <tr>
    <td>查看已安装的 package</td>
    <td><a href="https://cn.x-cmd.com/mod/env/ls">x env ls</a></td>
  </tr>
  <tr>
    <td>安装 package</td>
    <td><a href="https://cn.x-cmd.com/mod/env/use">x env use</a> &lt;package&gt;</td>
  </tr>
  <tr>
    <td>卸载 package<br>回收空间</td>
    <td>
      <a href="https://cn.x-cmd.com/mod/env/unuse">x env unuse</a> &lt;package&gt;<br>
      <a href="https://cn.x-cmd.com/mod/env/gc">x env gc</a> &lt;package&gt;
    </td>
  </tr>
  <tr>
    <td>仅在当前 Shell 安装使用 package</td>
    <td>
      <a href="https://cn.x-cmd.com/mod/env/try">x env try</a> &lt;package&gt;<br>
      <a href="https://cn.x-cmd.com/mod/env/untry">x env untry</a> &lt;package&gt;
    </td>
  </tr>
</table>


**使用**:

对于常用的 pkg，例如 `jq` :

1. **直接使用** : 通过 `x jq` 直接运行
2. **全局安装** : `x env use jq` 后使用 `jq` 命令
3. **临时安装** : `x env try jq` 后使用 `jq` 命令 ( 通过改变当前环境变量 PATH 以在当前会话的 Shell 生效 )

**更多介绍请查看**:

- [pkg 列表](https://cn.x-cmd.com/pkg/)
- [pkg get-started](https://cn.x-cmd.com/pkg/get-started)
- [关于 pkg](https://cn.x-cmd.com/pkg/diff-install-method)
- [提供 pkg](https://cn.x-cmd.com/pkg/submit)

## License

查看我们的 [License 说明](https://cn.x-cmd.com/start/license)

## 其他

- [X-CMD 社区](https://cn.x-cmd.com/start/community)
- [X-CMD 博客](https://cn.x-cmd.com/blog/)
- [X-CMD 变更日志](https://cn.x-cmd.com/v)
- [联系我们](https://cn.x-cmd.com/start/feedback)
- [反馈缺陷](https://github.com/x-cmd/x-cmd/issues/new?template=1-bug-report.yml)

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=x-cmd/x-cmd&type=Date)](https://star-history.com/#x-cmd/x-cmd&Date)
