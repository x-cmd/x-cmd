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


## [Poweruser Recommendation](https://x-cmd.com/powercommander)

|  |  |  |
| --- | --- | --- |
| **[Shodan](https://www.linkedin.com/posts/shodan_x-cmd-is-a-cli-that-supports-all-shodan-apis-activity-7212170285460938752-BUhs)** | Leading Security Search Engine | X-CMD is a CLl that supports all Shodan APls and a ton more. It's actually crazy how many things it supports and allows for some cool combinations. |
| **[Ian Max Andolina](https://github.com/iandol)** | Institute of Neuroscience, Chinese Academy of Sciences | The landscape of CLI tools is vast and ever changing. x-cmd is like a cool travel guide, mapping out the possibilities and providing context for wherever you may go. Want to know what modern CLI tool can help with problem Z? x-cmd can guide you through its well documented and structured modules and packages (local docs and online extensions). Want to try that new tool quickly; x-cmd can do that too. Want a  more consistent interface across operating systems, x-cmd does that too. Helpful completions: check. Helpful and friendly developers: check. And it comes with a true shell geek factor because it is built on awk with a small core engine <1MB... Strongly recommended! |
| **[Tzer-Jen Wei](https://youtu.be/JD2LkV_h96o?si=GyHwaKhN8ykhZ0Wh)** | Assoc. Professor, NYCU / Google GDE | X-CMD is a very interesting tool that brings together various useful services and an attractive interface. Besides daily use, it is also particularly suitable for demos and presentations. Even audiences who are not familiar with the command line, or even a bit intimidated by it, should also be pleasantly surprised when they see its simple syntax and effects.|
| **[Dmitriy Akulov](https://globalping.io/)** | Founder of jsDelivr & Globalping | X-CMD is a great project that unifies lots of useful open source projects in a simple CLI tool. It allowed Globalping to reach a new user-base and simplify the installation for new users. |
| **[Minimal Devops](https://minimaldevops.com/x-cmd-the-swiss-army-knife-of-the-cli-08ade4eea048)** | Minimal DevOps Practice Technology Author | X-CMD isn’t just a convenience — it’s a smart model. Instead of memorizing 20 different syntaxes, you remember one pattern. Instead of losing time in setup, you spend it on actual work. You could keep cobbling together scripts and aliases, or you could have a single framework that grows with you. That’s why it earns the “Swiss Army Knife” nickname. |
| **[Hong](https://tech.mrleong.net)** | Founder, nnoractive Sdn. Bhd. / Senior Technical Blogger | X-CMD offers a fantastic UX for the CLI environment. I love the help documentation; it is incredibly readable, allowing me to figure out how to get things done quickly without wasting time on dense manpages. I highly recommend it to anyone who values efficiency in their workflow. |
| **[Yuliang Xiao](https://mikami520.github.io/)** | PhD Student at UofT / Researcher at Sunnybrook Research Institute / MSE, Johns Hopkins University | X-CMD is a highly integrated toolkit that saves you from the time-consuming and bug-prone process of searching for and assembling disparate tools. It covers most daily needs; in my research, it not only efficiently manages workflows (like conda/python) but also provides a rich set of commands. It significantly boosts efficiency for researchers. |
| **[Xinlu Lai](https://github.com/shareAI-lab/Kode-cli)** | ShareAI Lab Founder & CEO / Kode Agent Author / llama3 Chinese Version Author | X-CMD is the sharpest Swiss Army Knife I've seen this year, the last one was BusyBox many years ago. |
| **[Min Gong Ge](https://mp.weixin.qq.com/s/kYZyQQfa0HX3LqqrxSbrMw)** | Author of Linux System Operations and Maintenance Guide: From Beginner to Enterprise Practice / Focused on open-source technologies including Linux systems, heavy backend, and system cluster operations | Redefining "small and beautiful," x-cmd leverages its modular design to achieve the "one tool, a hundred uses" philosophy, serving as a powerful productivity booster for developers and SREs. If you’re looking for a "Swiss Army knife in your pocket," x-cmd might just be the perfect choice. |
| **[Mike](https://www.hi-linux.com)** | Senior Internet Engineer with 25 years of experience / Social Media Creator / 100k+ followers across platforms / Focused on internet products, engineering practices, and productivity tools | x-cmd truly transforms the command line from a "fragmented toolset" back into an "all-in-one workspace": a single command to centrally manage thousands of tools, with environments, AI, and execution all taken care of, making every operation in the terminal faster, more stable, and more hassle-free. |
| **[Adriano](https://github.com/nitefood)** | asn author / Open Source Enthusiast | terminal power users need complete control over their tools. But at the same time, most tools are tedious and verbose to work with. X-cmd fixes that, and does so elegantly. A real game changer. |
| **[Han Shu](https://mp.weixin.qq.com/s/DrWpwG-z4NeCn4F4AEsObQ)** | Developer of Nping and AI-Media2doc / Open Source Enthusiast | x-cmd is an incredibly interesting and practical tool. In the past, various CLI tools were scattered everywhere, but x-cmd offers a completely new approach—not just simple integration, but deep enhancement. As a developer, I’ve used many desktop toolkits to boost productivity, and x-cmd fills the gap where the terminal lacked a high-efficiency toolkit. In the age of AI, the fact that x-cmd integrates so many tools may bring even more surprises to everyone. |
| **[Adrian](https://github.com/adrianhsm)** | Technical VP / Chief Architect of New Energy / Senior System Architect | As an architect, what impresses me most about X-CMD is how efficiently it “adapts to business at the architecture level” — it empowers me to rapidly build workflows that align with my architectural design needs, without wasting effort on rebuilding the entire toolchain. |
| **[Fei Le Niao](https://mp.weixin.qq.com/s/oxifrnyjwnKtNr3-DL2VFg)** | Senior Java Developer / CSDN Blogger / Open Source Enthusiast | A lightweight and highly efficient CLI toolkit. By seamlessly integrating package management, environment setup, and powerful shortcuts, it makes terminal workflows feel effortless and doubles developer productivity. |
| **[Li Wang](https://github.com/amslime)** | Chief Algorithm Engineer / NOIP Judge / ACM-ICPC Gold Medal | What X-CMD really saves is my brainpower. All the aliases and single-use scripts I used to memorize are now proper modules with discoverable commands. I can finally focus on solving problems instead of recalling weird one-liners. |
| **[CoderWanFeng](https://space.bilibili.com/259649365)** | 300K followers across all platforms / Author of python-office / Co-founder of the AI community "White Water AI" | X-CMD is a remarkable command-line tool whose modular design and quick invocation style align perfectly with our development philosophy. With just a simple command, you can access powerful and diverse features. Highly recommended for all developers who strive for efficient workflows. |
| **[Heqi Liu](https://github.com/Metaphorme)** | Focused on AI-assisted vaccine design / China Pharmaceutical University | X-CMD is a well-designed, cross-platform, and beginner-friendly modular CLI toolkit. Its near-transparent setup lets users focus on problem-solving rather than environment configuration. By consistently integrating and standardizing open-source CLI tools with high-quality documentation and tutorials, X-CMD enables rapid adoption of new community projects. Efficient communication and responsive iteration reflect its open, inclusive, and deeply open-source–driven philosophy. I am confident in its long-term evolution. |
| **Nxcode** | nxcode.io | Want your AI to level up from simple conversations to real engineering power? X-CMD is the secret weapon—it takes care of all the hard system operations. |
| **[Zhongnan Huluwa](https://infmax.top)** | UCAS-ICT / Senior Internet Engineer / Author of iTrending.top | I was immediately drawn to x-cmd the first time I saw it. It strikes a rare balance between efficiency and aesthetics, significantly simplifying and standardizing the deployment of terminal tools. In the age of AI, x-cmd feels more alive than ever. As a terminal enthusiast, I sincerely hope x-cmd continues to grow stronger. |
| **[EricWang](https://x.com/ssslvky)** | MemoV Founder | Agents are only as capable as their shell. X-CMD gives you a lightweight, instantly deployable shell interface—so your agents can act fast, automate deeper, and ship real work. |
| **[MeetChances](https://talent.meetchances.com/jobs?_fr=xcmd)** | meetchances.com | With the rise of AI Coding, the wheel of technology is turning back to the terminal once again. X-CMD helps experts on the QianShi platform efficiently resolve environment configuration and toolchain issues, significantly improving development and delivery efficiency. Highly recommended for industry professionals — the earlier you adopt X-CMD, the earlier you get off work. |
| **[Huaping Fiberglass](https://huaping-fiberglass.com/)** | huaping-fiberglass.com | Sincerely thank the X-CMD team for their guidance! Our operations team has taken the lead in adopting x-cmd and x-cmd hub in internal testing, successfully achieving the sharing of prompts and scripts. We are particularly excited about the immense potential of integrating AI Agents and Skills into our CI/CD and daily workflows. In the AI era, the importance of such capabilities is self-evident, bringing unlimited associations and possibilities. We wish X-CMD great success in the AI era! |
| **[Nick Young](https://github.com/Nick2bad4u)** | Senior Systems/Network Engineer at TDS Consulting | I used to sync portable apps via Dropbox across multiple PCs. Now, x-cmd has completely replaced that workflow—it’s essentially a massive toolbox containing almost every app I need. It’s significantly quicker and easier than manual setup. |
| **[Marek Küthe](https://mk16.de/)** | Open Source Enthusiast | My personal highlight of x-cmd is, on the one hand, the excellent documentation, which includes examples as well as a reference guide for use. On the other hand, it's also the visual presentation. Furthermore, it doesn't "pressure" you and gives you a lot of freedom. |
| **[Cierra Runis](https://note-of-me.top/)** | Open Source Enthusiast | x-cmd encapsulates common system and network operations into safer, user-friendly commands. Its interactive design lowers the barrier to using and memorizing CLI tools, while its Shell-based implementation eliminates the need for extra runtimes or dependency management—ensuring a pragmatic, reliable, and "out-of-the-box" experience. |
| **[Wu Haomian](https://x-cmd.com)** | Outstanding Physics Teacher / EdTech Innovator | Physics explores the universe; x-cmd masters digital logic. Its intuitive design and AI integration make terminal usage effortless for educators. A perfect tool for non-CS majors to boost efficiency in teaching and research. |
