English | [中文](README.cn.md) | [Source Code](https://github.com/x-cmd/x-cmd/tree/main/mod) ⭐ <a target="_blank" href="https://x-cmd.com/v"><img align="right"  alt="x-cmd-version" src="https://img.shields.io/github/v/release/x-cmd/x-cmd?label=latest&labelColor=107fbc&color=107fbc"></a>

<p align="center">
    <a target="_blank" href="https://x-cmd.com/">
        <img src="https://user-images.githubusercontent.com/40693636/218274071-92a26d84-0550-4b90-a0ba-7d54118c56e1.png" alt="x-cmd-logo" width="140">
    </a>
</p>

<h1 align="center"><a href="https://x-cmd.com/">X-CMD</a></h1>

<p align="center">
  <b>Your AI-Powered Excalibur in Cloud.</b>
  <br>
  <a href="https://x-cmd.com/">https://x-cmd.com</a>
</p>


## [Introduction](https://x-cmd.com)

X-CMD (pronounced as "*X Command*") is a compact yet powerful command-line toolkit that offers over <ins>100+</ins> functional modules tailored for various use cases, along with a package manager that supports downloading and installing over <ins>500+</ins> third-party open-source CLI tools.


- ⚡ **Bootstrap 1000+ CLI tools**: One command, download on-demand, launch CLI like apps.
- 🧠 **AI-Powered**: AI agent, AI chat, AI tasks, AI generator ... — one command to owner your efficient copilot.
- 🧩 **Environment Management**: Smoothly set up Node, Python, Java, Go … development environments
- 🛡️ **Secure Sandbox**: Provide permission-controlled system sandbox and Docker-based isolation — run software safely.
- 🎨 **Terminal Beautifier**: Built-in switch terminal theme & primary color, fonts installation, quickpath navigation and native completions — stylish and efficient.
- ∞ **Design & UX**: Unified CLI style, intuitive terminal UI, smooth workflows, effortless terminal experience.
- 🗃️ **Hub**: Instantly run hosted scripts across different platforms and shells, even in lightweight containers like BusyBox and Alpine.
- 🪶 **Lightweight**: Core package ~ 1.1 MB, loads in ~ 100 ms.

[![x-cmd-banner](https://cdn.jsdelivr.net/gh/Zhengqbbb/Zhengqbbb@v1.2.2/x-cmd/x-cmd-banner.png)](https://x-cmd.com)

<pre align="center">
For <bold>source code</bold>, please visit <a href="https://github.com/x-cmd/x-cmd/tree/main/mod">main</a> branch.
<a href="https://github.com/x-cmd/x-cmd/tree/X/README.md">X</a> branch is for demo and action ⭐
</pre>

## [Installation](https://x-cmd.com/start/)

Run the official X-CMD installation [script](https://github.com/x-cmd/get/blob/main/index.html) in most common shells (**bash, zsh, dash, ash**).

- With `curl` command:
  ```sh
  eval "$(curl https://get.x-cmd.com)"
  ```
- With `wget` command:
  ```sh
  eval "$(wget -O- https://get.x-cmd.com)"
  ```

<table>
<tbody>
<tr>
<td width="1000px">

**Installation Detailed Guide - Platform**:

[🐧 Linux and macOS 🍎](https://x-cmd.com/start/linux) &nbsp; | &nbsp; [🟦 Windows](https://x-cmd.com/start/windows) &nbsp; | &nbsp; [🔴 BSD](https://www.x-cmd.com/start/bsd)

**Installation Detailed Guide - Non-POSIX Shell**:

[fish](https://x-cmd.com/start/fish) &nbsp; | &nbsp; [Nushell](https://x-cmd.com/start/nushell) &nbsp; | &nbsp; [Elvish](https://x-cmd.com/start/elvish) &nbsp; | &nbsp; [Xonsh](https://x-cmd.com/start/xonsh) &nbsp; | &nbsp; [tcsh](https://x-cmd.com/start/tcsh) &nbsp; | &nbsp; [PowerShell](https://x-cmd.com/start/powershell)

**Installation Detailed Guide - Package Manager**:

[brew](https://x-cmd.com/start/#homebrew) &nbsp; | &nbsp; [aur](https://x-cmd.com/start/#homebrew) &nbsp; | &nbsp; [apt](https://x-cmd.com/start/#apt) &nbsp; | &nbsp; [apk](https://x-cmd.com/start/#apk) &nbsp; | &nbsp; [pacman](https://x-cmd.com/start/#pacman) &nbsp; | &nbsp; [dnf](https://x-cmd.com/start/#dnf)

</td>
</tr>
</tbody>
</table>

## [Synopsis](https://x-cmd.com/start/design)

<p align="center">
<a href="https://x-cmd.com/start/design">
<img align="center" width="640" alt="Image" src="https://cdn.jsdelivr.net/gh/Zhengqbbb/Zhengqbbb@v1.2.2/x-cmd/x-cmd-synopsis.png" />
</a>
</p>

## [Module](https://x-cmd.com/mod/)

Functional modules (mod) provided by X-CMD, invoked using the `x <mod>`.
<br>
For more information see [mod/get-started](https://www.x-cmd.com/mod/get-started)

<table>
<tr>
<td width="500px"> 🤖 Agent </td>
<td width="500px"> 🧠 AI </td>
</tr>
<tr>
<td width="500px">

```sh
x claude
x codex
x crush
...
```

</td>
<td width="500px">

```sh
x openai
x gemini
x deepseek
...
```

</td>
</tr>

<tr>
<td width="500px"> 🖥️ OS Man. </td>
<td width="500px"> 📁 File System & Storage </td>
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
<td width="500px"> 📦 Package Manager </td>
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

[More...](https://www.x-cmd.com/mod/)

</td>
</tr>
</table>
<br>

## [Package](https://www.x-cmd.com/pkg/)

Packages collected by X-CMD, managed by the [env](https://www.x-cmd.com/mod/env) module.

<table>
  <tr>
    <th width="500px">Description</th>
    <th width="500px">Command</th>
  </tr>
  <tr>
    <td>Interactively view installable packages</td>
    <td><a href="https://www.x-cmd.com/mod/env">x env</a></td>
  </tr>
  <tr>
    <td>View installed packages</td>
    <td><a href="https://www.x-cmd.com/mod/env/ls">x env ls</a></td>
  </tr>
  <tr>
    <td>Install package</td>
    <td><a href="https://www.x-cmd.com/mod/env/use">x env use</a> &lt;package&gt;</td>
  </tr>
  <tr>
    <td>Uninstall package<br>Reclaim space</td>
    <td>
      <a href="https://www.x-cmd.com/mod/env/unuse">x env unuse</a> &lt;package&gt;<br>
      <a href="https://www.x-cmd.com/mod/env/gc">x env gc</a> &lt;package&gt;
    </td>
  </tr>
  <tr>
    <td>Install and use package only in the current Shell</td>
    <td>
      <a href="https://www.x-cmd.com/mod/env/try">x env try</a> &lt;package&gt;<br>
      <a href="https://www.x-cmd.com/mod/env/untry">x env untry</a> &lt;package&gt;
    </td>
  </tr>
</table>


**General Usage:**

For commonly used packages, e.g `jq` :

1. **Direct Use** : Run directly with `x jq`
2. **Global Installation** : After `x env use jq`, use the `jq` command
3. **Temporary Installation** : After `x env try jq`, use the `jq` command (by modifying the current environment variable PATH to take effect in the current session's Shell)

**For more information see:**

- [pkg list](https://www.x-cmd.com/pkg/)
- [pkg get-started](https://www.x-cmd.com/pkg/get-started)
- [about pkg](https://www.x-cmd.com/pkg/diff-install-method)
- [submit pkg](https://www.x-cmd.com/pkg/submit)

## License

See our [License Explanation](https://www.x-cmd.com/start/license).

## Other

- [X-CMD Community](https://www.x-cmd.com/start/community)
- [X-CMD Blog](https://www.x-cmd.com/blog/)
- [X-CMD Changelog](https://www.x-cmd.com/v)
- [Contact Us](https://www.x-cmd.com/start/feedback)
- [Report Bug](https://github.com/x-cmd/x-cmd/issues/new?template=1-bug-report.yml)

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=x-cmd/x-cmd&type=Date)](https://star-history.com/#x-cmd/x-cmd&Date)
