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
x opencode
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


## [Poweruser Recommendation](https://x-cmd.com/powercommander)

<!-- Poweruser Recommendation Insert -->
<table>
<tr>
<td width="500px">
<p align="center">
<br>
<a href="https://www.linkedin.com/posts/shodan_x-cmd-is-a-cli-that-supports-all-shodan-apis-activity-7212170285460938752-BUhs"><kbd><img alt="Shodan's avatar" width="60" src="https://www.x-cmd.com/data-image/avatar/avatar-shodan.webp"></kbd></a><br>
<a href="https://www.linkedin.com/posts/shodan_x-cmd-is-a-cli-that-supports-all-shodan-apis-activity-7212170285460938752-BUhs">Shodan</a>
<br>
</p>
<samp>
<ul>
<li>@shodanhq · shodan.io</li>
<li>Leading Security Search Engine</li>
<li>Global Cybersecurity Intelligence Platform</li>
</ul>
</samp>
</td>
<td width="500px">
X-CMD is a CLl that supports all Shodan APls and a ton more. It's actually crazy how many things it supports and allows for some cool combinations: https://www.x-cmd.com<br><br>The Shodan commands are documented here: https://x-cmd.com/mod/shodan<br><br>And here's a short example of doing a search on a vulnerability and then feeding it to an AI model. Or getting a list of Known Exploited Vulnerabilities (KEV) based on CISA:
</td>
</tr>

<tr>
<td width="500px">
<p align="center">
<br>
<a href="https://youtu.be/JD2LkV_h96o?si=GyHwaKhN8ykhZ0Wh"><kbd><img alt="Tzer-Jen Wei, Ph.D.'s avatar" width="60" src="https://www.x-cmd.com/data-image/avatar/avatar-tjwei.webp"></kbd></a><br>
<a href="https://youtu.be/JD2LkV_h96o?si=GyHwaKhN8ykhZ0Wh">Tzer-Jen Wei, Ph.D.</a>
<br>
</p>
<samp>
<ul>
<li>Associate Professor, NYCU AI College</li>
<li>Google Developer Expert in Machine Learning</li>
<li>AWS Educate Cloud Ambassador</li>
</ul>
</samp>
</td>
<td width="500px">
X-CMD is a very interesting tool that brings together various useful services and an attractive interface.<br>Besides daily use, it is also particularly suitable for demos and presentations.<br>Even audiences who are not familiar with the command line, or even a bit intimidated by it,<br>should also be pleasantly surprised when they see its simple syntax and effects.
</td>
</tr>

<tr>
<td width="500px">
<p align="center">
<br>
<a href="https://github.com/iandol"><kbd><img alt="Ian Max Andolina Ph.D.'s avatar" width="60" src="https://www.x-cmd.com/data-image/avatar/avatar-iandol.webp"></kbd></a><br>
<a href="https://github.com/iandol">Ian Max Andolina Ph.D.</a>
<br>
</p>
<samp>
<ul>
<li>Neuroscientist specializing in visual perception</li>
<li>Institute of Neuroscience, Chinese Academy of Sciences</li>
</ul>
</samp>
</td>
<td width="500px">
The landscape of CLI tools is vast and ever changing. x-cmd is like a cool travel guide, mapping out the possibilities and providing context for wherever you may go.<br>Want to know what modern CLI tool can help with problem Z? x-cmd can guide you through its well documented and structured modules and packages (local docs and online extensions). Want to try that new tool quickly; x-cmd can do that too. Want a  more consistent interface across operating systems, x-cmd does that too. Helpful completions: check. Helpful and friendly developers: check.<br>And it comes with a true shell geek factor because it is built on awk with a small core engine <1MB... Strongly recommended!
</td>
</tr>

<tr>
<td width="500px">
<p align="center">
<br>
<a href="https://terminaltrove.com/x-cmd/"><kbd><img alt="Terminal Trove's avatar" width="60" src="https://www.x-cmd.com/data-image/avatar/avatar-terminal_trove.webp"></kbd></a><br>
<a href="https://terminaltrove.com/x-cmd/">Terminal Trove</a>
<br>
</p>
<samp>
<ul>
<li>The $HOME of Terminal Tools</li>
<li>The Curated CLI Directory</li>
</ul>
</samp>
</td>
<td width="500px">
This tool is ideal for developers, engineers and CLI power users who want a unified toolset.<br>It's useful if you need to manage everything from version managers to cloud commands accessible in one toolset.
</td>
</tr>

<tr>
<td width="500px">
<p align="center">
<br>
<a href="https://www.howtogeek.com"><kbd><img alt="How-To Geek's avatar" width="60" src="https://www.x-cmd.com/data-image/avatar/avatar-howtogeek.webp"></kbd></a><br>
<a href="https://www.howtogeek.com">How-To Geek</a>
<br>
</p>
<samp>
<ul>
<li>Leading Technology Explainer</li>
<li>Online Consumer Electronics Guide</li>
</ul>
</samp>
</td>
<td width="500px">
x-cmd describes itself in many ways, but at its core, it's portable, convenient, and hassle-free. In keeping with that spirit, you can deploy it to any system with a simple curl command.
</td>
</tr>

<tr>
<td width="500px">
<p align="center">
<br>
<a href="https://minimaldevops.com/x-cmd-the-swiss-army-knife-of-the-cli-08ade4eea048"><kbd><img alt="Minimal Devops's avatar" width="60" src="https://www.x-cmd.com/data-image/avatar/avatar-minimaldev.webp"></kbd></a><br>
<a href="https://minimaldevops.com/x-cmd-the-swiss-army-knife-of-the-cli-08ade4eea048">Minimal Devops</a>
<br>
</p>
<samp>
<ul>
<li>Minimal DevOps Practice Technology Author</li>
</ul>
</samp>
</td>
<td width="500px">
X-CMD isn’t just a convenience — it’s a smart model. Instead of memorizing 20 different syntaxes, you remember one pattern. Instead of losing time in setup, you spend it on actual work.<br><br>You could keep cobbling together scripts and aliases, or you could have a single framework that grows with you. That’s why it earns the “Swiss Army Knife” nickname.
</td>
</tr>

<tr>
<td width="500px">
<p align="center">
<br>
<a href="https://globalping.io/"><kbd><img alt="Dmitriy Akulov's avatar" width="60" src="https://www.x-cmd.com/data-image/avatar/avatar-dmitriy.webp"></kbd></a><br>
<a href="https://globalping.io/">Dmitriy Akulov</a>
<br>
</p>
<samp>
<ul>
<li>Founder of jsDelivr</li>
<li>Creator of Globalping</li>
</ul>
</samp>
</td>
<td width="500px">
X-CMD is a great project that unifies lots of useful open source projects in a simple CLI tool. It allowed Globalping to reach a new user-base and simplify the installation for new users.
</td>
</tr>

<tr>
<td width="500px">
<p align="center">
<br>
<a href="https://tech.mrleong.net"><kbd><img alt="Hong's avatar" width="60" src="https://www.x-cmd.com/data-image/avatar/avatar-hong.webp"></kbd></a><br>
<a href="https://tech.mrleong.net">Hong</a>
<br>
</p>
<samp>
<ul>
<li>Founder, nnoractive Sdn. Bhd.</li>
<li>Senior Technical Blogger</li>
</ul>
</samp>
</td>
<td width="500px">
X-CMD offers a fantastic UX for the CLI environment. I love the help documentation; it is incredibly readable, allowing me to figure out how to get things done quickly without wasting time on dense manpages. I highly recommend it to anyone who values efficiency in their workflow.
</td>
</tr>

<tr>
<td width="500px">
<p align="center">
<br>
<a href="https://mikami520.github.io/"><kbd><img alt="Yuliang Xiao's avatar" width="60" src="https://www.x-cmd.com/data-image/avatar/avatar-yuliangxiao.webp"></kbd></a><br>
<a href="https://mikami520.github.io/">Yuliang Xiao</a>
<br>
</p>
<samp>
<ul>
<li>PhD Student at UofT</li>
<li>Researcher at Sunnybrook Research Institute</li>
<li>MSE, Johns Hopkins University</li>
</ul>
</samp>
</td>
<td width="500px">
X-CMD is a highly integrated toolkit that saves you from the time-consuming and bug-prone process of searching for and assembling disparate tools. It covers most daily needs; in my research, it not only efficiently manages workflows (like conda/python) but also provides a rich set of commands. It significantly boosts efficiency for researchers.
</td>
</tr>

<tr>
<td width="500px">
<p align="center">
<br>
<a href="https://github.com/shareAI-lab/Kode-cli"><kbd><img alt="Xinlu Lai's avatar" width="60" src="https://www.x-cmd.com/data-image/avatar/avatar-laixinlu.webp"></kbd></a><br>
<a href="https://github.com/shareAI-lab/Kode-cli">Xinlu Lai</a>
<br>
</p>
<samp>
<ul>
<li>ShareAI Lab Founder & CEO</li>
<li>Kode Agent Author</li>
<li>llama3 Chinese Version Author</li>
</ul>
</samp>
</td>
<td width="500px">
X-CMD is the sharpest Swiss Army Knife I've seen this year, the last one was BusyBox many years ago.
</td>
</tr>

<tr>
<td width="500px">
<p align="center">
<br>
<a href="https://mp.weixin.qq.com/s/kYZyQQfa0HX3LqqrxSbrMw"><kbd><img alt="Min Gong Ge's avatar" width="60" src="https://www.x-cmd.com/data-image/avatar/avatar-mingge.webp"></kbd></a><br>
<a href="https://mp.weixin.qq.com/s/kYZyQQfa0HX3LqqrxSbrMw">Min Gong Ge</a>
<br>
</p>
<samp>
<ul>
<li>Author of Linux System Operations and Maintenance Guide: From Beginner to Enterprise Practice</li>
<li>Focused on open-source technologies including Linux systems, heavy backend, and system cluster operations</li>
</ul>
</samp>
</td>
<td width="500px">
Redefining "small and beautiful," x-cmd leverages its modular design to achieve the "one tool, a hundred uses" philosophy, serving as a powerful productivity booster for developers and SREs.<br>If you’re looking for a "Swiss Army knife in your pocket," x-cmd might just be the perfect choice.
</td>
</tr>

<tr>
<td width="500px">
<p align="center">
<br>
<a href="https://www.hi-linux.com"><kbd><img alt="Mike's avatar" width="60" src="https://www.x-cmd.com/data-image/avatar/avatar-linux.webp"></kbd></a><br>
<a href="https://www.hi-linux.com">Mike</a>
<br>
</p>
<samp>
<ul>
<li>Senior Internet Engineer with 25 years of experience</li>
<li>Social Media Creator / 100k+ followers across platforms</li>
<li>Focused on internet products, engineering practices, and productivity tools</li>
</ul>
</samp>
</td>
<td width="500px">
x-cmd truly transforms the command line from a "fragmented toolset" back into an "all-in-one workspace": a single command to centrally manage thousands of tools, with environments, AI, and execution all taken care of, making every operation in the terminal faster, more stable, and more hassle-free.
</td>
</tr>

<tr>
<td width="500px">
<p align="center">
<br>
<a href="https://github.com/nitefood"><kbd><img alt="Adriano's avatar" width="60" src="https://www.x-cmd.com/data-image/avatar/avatar-adriano.webp"></kbd></a><br>
<a href="https://github.com/nitefood">Adriano</a>
<br>
</p>
<samp>
<ul>
<li>asn author</li>
<li>Open Source Enthusiast</li>
</ul>
</samp>
</td>
<td width="500px">
terminal power users need complete control over their tools. But at the same time, most tools are tedious and verbose to work with. X-cmd fixes that, and does so elegantly. A real game changer.
</td>
</tr>

<tr>
<td width="500px">
<p align="center">
<br>
<a href="https://mp.weixin.qq.com/s/DrWpwG-z4NeCn4F4AEsObQ"><kbd><img alt="Han Shu's avatar" width="60" src="https://www.x-cmd.com/data-image/avatar/avatar-hanshu.webp"></kbd></a><br>
<a href="https://mp.weixin.qq.com/s/DrWpwG-z4NeCn4F4AEsObQ">Han Shu</a>
<br>
</p>
<samp>
<ul>
<li>Developer of Nping and AI-Media2doc</li>
<li>Open Source Enthusiast</li>
</ul>
</samp>
</td>
<td width="500px">
x-cmd is an incredibly interesting and practical tool. In the past, various CLI tools were scattered everywhere, but x-cmd offers a completely new approach—not just simple integration, but deep enhancement.<br>As a developer, I’ve used many desktop toolkits to boost productivity, and x-cmd fills the gap where the terminal lacked a high-efficiency toolkit. In the age of AI, the fact that x-cmd integrates so many tools may bring even more surprises to everyone.
</td>
</tr>

<tr>
<td width="500px">
<p align="center">
<br>
<a href="https://dusays.com/768/"><kbd><img alt="TeacherDu's avatar" width="60" src="https://www.x-cmd.com/data-image/avatar/avatar-dusays.webp"></kbd></a><br>
<a href="https://dusays.com/768/">TeacherDu</a>
<br>
</p>
<samp>
<ul>
<li>Cloud Computing Instructor</li>
<li>Senior DevOps Engineer</li>
</ul>
</samp>
</td>
<td width="500px">
X-CMD is a powerful tool for enhancing the terminal experience. Its modular design and integrated package manager provide a rich set of features with a smooth learning curve. Whether for daily command-line tasks or setting up a development environment, X-CMD offers reliable and efficient support. Highly recommended.
</td>
</tr>

<tr>
<td width="500px">
<p align="center">
<br>
<a href="https://github.com/adrianhsm"><kbd><img alt="Adrian's avatar" width="60" src="https://www.x-cmd.com/data-image/avatar/avatar-shengming.webp"></kbd></a><br>
<a href="https://github.com/adrianhsm">Adrian</a>
<br>
</p>
<samp>
<ul>
<li>Technical VP</li>
<li>Chief Architect of New Energy</li>
<li>Senior System Architect</li>
</ul>
</samp>
</td>
<td width="500px">
As an architect, what impresses me most about X-CMD is how efficiently it “adapts to business at the architecture level” — it empowers me to rapidly build workflows that align with my architectural design needs, without wasting effort on rebuilding the entire toolchain.
</td>
</tr>

<tr>
<td width="500px">
<p align="center">
<br>
<a href="https://mp.weixin.qq.com/s/oxifrnyjwnKtNr3-DL2VFg"><kbd><img alt="Fei Le Niao's avatar" width="60" src="https://www.x-cmd.com/data-image/avatar/avatar-feiniao.webp"></kbd></a><br>
<a href="https://mp.weixin.qq.com/s/oxifrnyjwnKtNr3-DL2VFg">Fei Le Niao</a>
<br>
</p>
<samp>
<ul>
<li>Senior Java Developer</li>
<li>CSDN Blogger</li>
<li>Open Source Enthusiast</li>
</ul>
</samp>
</td>
<td width="500px">
A lightweight and highly efficient CLI toolkit. By seamlessly integrating package management, environment setup, and powerful shortcuts, it makes terminal workflows feel effortless and doubles developer productivity.
</td>
</tr>

<tr>
<td width="500px">
<p align="center">
<br>
<a href="https://github.com/amslime"><kbd><img alt="Li Wang's avatar" width="60" src="https://www.x-cmd.com/data-image/avatar/avatar-wangli.webp"></kbd></a><br>
<a href="https://github.com/amslime">Li Wang</a>
<br>
</p>
<samp>
<ul>
<li>Chief Algorithm Engineer</li>
<li>NOIP Judge</li>
<li>ACM-ICPC Gold Medal</li>
</ul>
</samp>
</td>
<td width="500px">
What X-CMD really saves is my brainpower. All the aliases and single-use scripts I used to memorize are now proper modules with discoverable commands. I can finally focus on solving problems instead of recalling weird one-liners.
</td>
</tr>

<tr>
<td width="500px">
<p align="center">
<br>
<a href="https://github.com/ilyydy"><kbd><img alt="Chi Zhang's avatar" width="60" src="https://www.x-cmd.com/data-image/avatar/avatar-zhangchi.webp"></kbd></a><br>
<a href="https://github.com/ilyydy">Chi Zhang</a>
<br>
</p>
<samp>
<ul>
<li>Senior Node.js Developer</li>
</ul>
</samp>
</td>
<td width="500px">
I often need to switch between about ten machine terminals for work. Syncing script configurations and unifying tool installations has always been a headache. Thanks to x-cmd, it provides a simple and fast solution to achieve consistency across multiple terminals at a very low cost. Life is precious, I use x-cmd.
</td>
</tr>

<tr>
<td width="500px">
<p align="center">
<br>
<a href="https://space.bilibili.com/259649365"><kbd><img alt="CoderWanFeng's avatar" width="60" src="https://www.x-cmd.com/data-image/avatar/avatar-wanfeng.webp"></kbd></a><br>
<a href="https://space.bilibili.com/259649365">CoderWanFeng</a>
<br>
</p>
<samp>
<ul>
<li>300K followers across all platforms</li>
<li>Author of python-office</li>
<li>Co-founder of the AI community "White Water AI"</li>
</ul>
</samp>
</td>
<td width="500px">
X-CMD is a remarkable command-line tool whose modular design and quick invocation style align perfectly with our development philosophy. With just a simple command, you can access powerful and diverse features. Highly recommended for all developers who strive for efficient workflows.
</td>
</tr>

<tr>
<td width="500px">
<p align="center">
<br>
<a href="https://github.com/Metaphorme"><kbd><img alt="Heqi Liu's avatar" width="60" src="https://www.x-cmd.com/data-image/avatar/avatar-liuheqi.webp"></kbd></a><br>
<a href="https://github.com/Metaphorme">Heqi Liu</a>
<br>
</p>
<samp>
<ul>
<li>Focused on AI-assisted vaccine design</li>
<li>China Pharmaceutical University</li>
</ul>
</samp>
</td>
<td width="500px">
X-CMD is a well-designed, cross-platform, and beginner-friendly modular CLI toolkit. Its near-transparent setup lets users focus on problem-solving rather than environment configuration.<br>By consistently integrating and standardizing open-source CLI tools with high-quality documentation and tutorials, X-CMD enables rapid adoption of new community projects. Efficient communication and responsive iteration reflect its open, inclusive, and deeply open-source–driven philosophy.<br>I am confident in its long-term evolution.
</td>
</tr>

<tr>
<td width="500px">
<p align="center">
<br>
<a href="https://x.com/nxcode_io"><kbd><img alt="Nxcode's avatar" width="60" src="https://www.x-cmd.com/data-image/avatar/avatar-nxcode.webp"></kbd></a><br>
<a href="https://x.com/nxcode_io">Nxcode</a>
<br>
</p>
<samp>
<ul>
<li>nxcode.io</li>
</ul>
</samp>
</td>
<td width="500px">
Want your AI to level up from simple conversations to real engineering power?<br>X-CMD is the secret weapon—it takes care of all the hard system operations.
</td>
</tr>

<tr>
<td width="500px">
<p align="center">
<br>
<a href="https://infmax.top"><kbd><img alt="Zhongnan Huluwa's avatar" width="60" src="https://www.x-cmd.com/data-image/avatar/avatar-huluwa.webp"></kbd></a><br>
<a href="https://infmax.top">Zhongnan Huluwa</a>
<br>
</p>
<samp>
<ul>
<li>UCAS-ICT</li>
<li>Senior Internet Engineer</li>
<li>Author of iTrending.top</li>
</ul>
</samp>
</td>
<td width="500px">
I was immediately drawn to x-cmd the first time I saw it. It strikes a rare balance between efficiency and aesthetics, significantly simplifying and standardizing the deployment of terminal tools.<br>In the age of AI, x-cmd feels more alive than ever. As a terminal enthusiast, I sincerely hope x-cmd continues to grow stronger.
</td>
</tr>

<tr>
<td width="500px">
<p align="center">
<br>
<a href="https://x.com/ssslvky"><kbd><img alt="EricWang's avatar" width="60" src="https://www.x-cmd.com/data-image/avatar/avatar-ericwang.webp"></kbd></a><br>
<a href="https://x.com/ssslvky">EricWang</a>
<br>
</p>
<samp>
<ul>
<li>MemoV Founder</li>
</ul>
</samp>
</td>
<td width="500px">
Agents are only as capable as their shell.<br>X-CMD gives you a lightweight, instantly deployable shell interface—so your agents can act fast, automate deeper, and ship real work.
</td>
</tr>

<tr>
<td width="500px">
<p align="center">
<br>
<a href="https://talent.meetchances.com/jobs?_fr=xcmd"><kbd><img alt="MeetChances's avatar" width="60" src="https://www.x-cmd.com/data-image/avatar/avatar-meetchances.webp"></kbd></a><br>
<a href="https://talent.meetchances.com/jobs?_fr=xcmd">MeetChances</a>
<br>
</p>
<samp>
<ul>
<li>meetchances.com</li>
</ul>
</samp>
</td>
<td width="500px">
With the rise of AI Coding, the wheel of technology is turning back to the terminal once again.<br>X-CMD helps experts on the QianShi platform efficiently resolve environment configuration and toolchain issues,<br>significantly improving development and delivery efficiency.<br>Highly recommended for industry professionals — the earlier you adopt X-CMD, the earlier you get off work.
</td>
</tr>

<tr>
<td width="500px">
<p align="center">
<br>
<a href="https://huaping-fiberglass.com/"><kbd><img alt="Huaping Fiberglass's avatar" width="60" src="https://www.x-cmd.com/data-image/avatar/avatar-huaping.webp"></kbd></a><br>
<a href="https://huaping-fiberglass.com/">Huaping Fiberglass</a>
<br>
</p>
<samp>
<ul>
<li>huaping-fiberglass.com</li>
</ul>
</samp>
</td>
<td width="500px">
Sincerely thank the X-CMD team for their guidance! Our operations team has taken the lead in adopting x-cmd and x-cmd hub in internal testing, successfully achieving the sharing of prompts and scripts. We are particularly excited about the immense potential of integrating AI Agents and Skills into our CI/CD and daily workflows. In the AI era, the importance of such capabilities is self-evident, bringing unlimited associations and possibilities. We wish X-CMD great success in the AI era!
</td>
</tr>

<tr>
<td width="500px">
<p align="center">
<br>
<a href="https://github.com/Nick2bad4u"><kbd><img alt="Nick Young's avatar" width="60" src="https://www.x-cmd.com/data-image/avatar/avatar-young.webp"></kbd></a><br>
<a href="https://github.com/Nick2bad4u">Nick Young</a>
<br>
</p>
<samp>
<ul>
<li>Senior Systems/Network Engineer at TDS Consulting</li>
</ul>
</samp>
</td>
<td width="500px">
I used to sync portable apps via Dropbox across multiple PCs. Now, x-cmd has completely replaced that workflow—it’s essentially a massive toolbox containing almost every app I need. It’s significantly quicker and easier than manual setup.
</td>
</tr>

<tr>
<td width="500px">
<p align="center">
<br>
<a href="https://mk16.de/"><kbd><img alt="Marek Küthe's avatar" width="60" src="https://www.x-cmd.com/data-image/avatar/avatar-marek22k.webp"></kbd></a><br>
<a href="https://mk16.de/">Marek Küthe</a>
<br>
</p>
<samp>
<ul>
<li>Open Source Enthusiast</li>
</ul>
</samp>
</td>
<td width="500px">
My personal highlight of x-cmd is, on the one hand, the excellent documentation, which includes examples as well as a reference guide for use. On the other hand, it's also the visual presentation.<br>Furthermore, it doesn't "pressure" you and gives you a lot of freedom.
</td>
</tr>

<tr>
<td width="500px">
<p align="center">
<br>
<a href="https://github.com/DerickIT"><kbd><img alt="Derick's avatar" width="60" src="https://www.x-cmd.com/data-image/avatar/avatar-derick.webp"></kbd></a><br>
<a href="https://github.com/DerickIT">Derick</a>
<br>
</p>
<samp>
<ul>
<li>Head of Technology at Polyflow</li>
<li>Blockchain Expert</li>
</ul>
</samp>
</td>
<td width="500px">
The measure of a great tool lies in its ability to maximize efficiency, and x-cmd is no exception. Tailored for developers, it provides an immersive, efficient, and consistent command-line interface experience through minimalist commands. One command in hand, unlocking infinite possibilities.
</td>
</tr>

<tr>
<td width="500px">
<p align="center">
<br>
<a href="https://note-of-me.top/"><kbd><img alt="Cierra Runis's avatar" width="60" src="https://www.x-cmd.com/data-image/avatar/avatar-cierrarunis.webp"></kbd></a><br>
<a href="https://note-of-me.top/">Cierra Runis</a>
<br>
</p>
<samp>
<ul>
<li>Open Source Enthusiast</li>
</ul>
</samp>
</td>
<td width="500px">
x-cmd encapsulates common system and network operations into safer, user-friendly commands. Its interactive design lowers the barrier to using and memorizing CLI tools, while its Shell-based implementation eliminates the need for extra runtimes or dependency management—ensuring a pragmatic, reliable, and "out-of-the-box" experience.
</td>
</tr>

<tr>
<td width="500px">
<p align="center">
<br>
<kbd><img alt="Wu Haomian's avatar" width="60" src="https://www.x-cmd.com/data-image/avatar/avatar-wuhaomian.webp"></kbd><br>
<b>Wu Haomian</b>
<br>
</p>
<samp>
<ul>
<li>Outstanding Physics Teacher</li>
<li>EdTech Innovator</li>
</ul>
</samp>
</td>
<td width="500px">
Physics explores the universe; x-cmd masters digital logic. Its intuitive design and AI integration make terminal usage effortless for educators. A perfect tool for non-CS majors to boost efficiency in teaching and research.
</td>
</tr>

<tr>
<td width="500px">
<p align="center">
<br>
<a href="https://hjj.huaping-fiberglass.com/"><kbd><img alt="Jacky Ho's avatar" width="60" src="https://www.x-cmd.com/data-image/avatar/avatar-hejiajie.webp"></kbd></a><br>
<a href="https://hjj.huaping-fiberglass.com/">Jacky Ho</a>
<br>
</p>
<samp>
<ul>
<li>Sales Director of FRP Products</li>
<li>Hardware Geek</li>
</ul>
</samp>
</td>
<td width="500px">
As the head of sales and operations, my core responsibility is to ensure that the value of our technology is accurately and reliably communicated to our customers. x-cmd has become a crucial link for efficient collaboration between me and the operations team. Through the x-cmd hub, we share standardized query and diagnostic scripts, allowing me to understand the system status immediately, communicate with the technical team using accurate data, and even provide clear technical support plans directly to customers. It has unified the "technical language" across departments, greatly improving the efficiency of internal collaboration from problem discovery to solution delivery.
</td>
</tr>

<tr>
<td colspan="2" align="center">
<a href="https://x-cmd.com/powercommander">
👉 See All Power Users ...
</a>
</td>
</tr>
</table>
<!-- Poweruser Recommendation End -->
