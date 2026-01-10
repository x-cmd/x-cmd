[English](README.md) | 中文 | [源码](https://github.com/x-cmd/x-cmd/tree/main/mod) ⭐ <a target="_blank" href="https://x-cmd.com/v"><img align="right"  alt="x-cmd-version" src="https://img.shields.io/github/v/release/x-cmd/x-cmd?label=latest&labelColor=107fbc&color=107fbc"></a>

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
        <td align="center" width="300px">
            &nbsp;<img align="center" src="https://foruda.gitee.com/images/1715696069230260264/d8037bf6_9641432.png" alt="公众号二维码，微信搜索：oh my x" />
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
- 🗃️ **Hub**: 随时随地运行自托管脚本，即使在 Alpine / Busybox 等极简容器镜像。
- 🪶 **极致轻量化**: 核心包体积 ~ 1.1 MB, 加载时间控制 ~ 100 ms.

[![x-cmd-banner](https://cdn.jsdelivr.net/gh/Zhengqbbb/Zhengqbbb@v1.2.2/x-cmd/x-cmd-banner.png)](https://cn.x-cmd.com)

<pre align="center">
查看源码请移步至 <a href="https://github.com/x-cmd/x-cmd/tree/main/mod">main</a> 分支
<a href="https://github.com/x-cmd/x-cmd/tree/X/README.md">X</a> 分支仅用于演示及构建 ⭐
</pre>

## [安装](https://cn.x-cmd.com/start/)

在常见 shell (bash, zsh, dash, ash) 中运行[官方安装脚本](https://github.com/x-cmd/get/blob/main/index.html)

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

## [用户评价](https://x-cmd.com/powercommander)

|  |  |  |
| --- | --- | --- |
| **[Shodan](https://www.linkedin.com/posts/shodan_x-cmd-is-a-cli-that-supports-all-shodan-apis-activity-7212170285460938752-BUhs)** | 全球最大的漏洞搜索引擎 | X-CMD 是一个支持所有 Shodan API 并且功能更多的命令行工具。它能支持和兼容的东西竟然有这么多，还能搭配出各种巧妙的组合，这简直令人难以置信。 |
| **[Ian Max Andolina](https://github.com/iandol)** | 中国科学院神经科学研究所 | CLI 工具的世界浩瀚无垠且瞬息万变。x-cmd 就像一位酷炫的向导，为你绘制探索蓝图，并提供全方位的指引。想知道哪个现代 CLI 工具能解决特定难题？x-cmd 能通过其结构清晰、文档详尽的模块和包（涵盖本地文档与在线扩展）为你指点迷津。想要快速尝鲜某个新工具？x-cmd 能满足你。想要在不同操作系统间获得一致的接口体验？x-cmd 也能做到。实用的自动补全：标配。热情友好的开发者：也是标配。而且它极具 Shell 极客情怀，因为它基于 awk 构建，核心引擎不足 1MB…… 强烈推荐 |
| **[魏泽人](https://youtu.be/JD2LkV_h96o?si=GyHwaKhN8ykhZ0Wh)** | 国立阳明交通大学副教授 / Google GDE | X-CMD 是一个非常有趣的工具，网罗多种有用的服务以及吸引人的界面。在日常使用之外，用于 demo 和展示也特别合适。即使是对命令行不熟悉、甚至有点畏惧的观众，看到简洁的语法和效果时，也应该会眼睛一亮。 |
| **[Dmitriy Akulov](https://globalping.io/)** | jsDelivr & Globalping 创始人 | X-CMD 是一个非常棒的项目，它在一个简单的 CLI 工具中整合了许多有用的开源项目。它让 Globalping 能够触达新的用户群体，并简化了新用户的安装流程。 |
| **[Minimal Devops](https://minimaldevops.com/x-cmd-the-swiss-army-knife-of-the-cli-08ade4eea048)** | 极简 DevOps 实践技术作者 | X-CMD 不只是一个方便的小工具——它是一套「聪明的模型」。你不再需要记住 20 种不同的语法，只要掌握一套通用模式。你不再把时间浪费在环境配置上，而是把时间花在真正的工作上。你当然可以继续东拼西凑脚本和别名；但你也可以选择一个会陪你一起成长的统一框架。这就是它为什么配得上 「瑞士军刀」 这个称号。 |
| **[Hong](https://tech.mrleong.net)** | nnoractive Sdn. Bhd. 创始人 / 资深技术博主 | X-CMD 为 CLI 环境提供了极佳的用户体验。我非常喜欢它的帮助文档，可读性极强，让我能快速找到解决方案，而无需在晦涩难懂的 man 手册上浪费时间。我高度推荐给任何重视工作流效率的人。 |
| **[肖宇亮](https://mikami520.github.io/)** | 多伦多大学博士生 / Sunnybrook 研究所研究员 / 约翰霍普金斯大学硕士 | X-CMD 是一个集成化很高的工具箱，它让你不需要花时间去找其他工具/包并把它们组合在一起，这样费时费力还有很多 bug。X-cmd 包含了绝大多数日常使用的功能，在我的科研工作中，不仅可以高效管理工作环境，如 conda/python，也可以提供丰富的操作指令。这大大地提升了科研工作者的效率。 |
| **[来新璐](https://github.com/shareAI-lab/Kode-cli)** | ShareAI Lab Founder & CEO / Kode Agent 作者 / llama3 中文版作者 | X-CMD 是我今年见到的最 sharp 的瑞士军刀，上一个是很多年前的 BusyBox。 |
| **[民工哥](https://mp.weixin.qq.com/s/kYZyQQfa0HX3LqqrxSbrMw)** | 《Linux 系统运维指南 从入门到企业实战》 作者 / 专注 Linux 系统、大后端、系统集群运维等开源技术 | 重新定义“小而美”，x-cmd 凭借模块化设计实现“一工具顶百款”，成为开发者与运维人员的效率利器。如果你想要一个“装在口袋里的瑞士军刀”，x-cmd 或许是最佳选择。 |
| **[Mike](https://www.hi-linux.com)** | 25 年资深互联网工程师 / 自媒体作者 / 全网粉丝 10w+ / 专注互联网产品、工程实践与效率工具 | x-cmd 真正把命令行从「工具碎片化」拉回到「一站式工作台」：一个命令统一管理上千工具，环境、AI、运行全搞定，让我在终端里的每一步都更快、更稳、更省心。 |
| **[Adriano](https://github.com/nitefood)** | asn 作者 / 开源爱好者 | 终端高级用户需要对他们的工具有完全的控制权。但与此同时，大多数工具使用起来既繁琐又冗长。x-cmd 解决了这个问题，而且处理得非常优雅。这是一个真正的游戏规则改变者。|
| **[韩数同学](https://mp.weixin.qq.com/s/DrWpwG-z4NeCn4F4AEsObQ)** | Nping 与 AI-Media2doc 开发者 / 开源爱好者 | x-cmd 是一个非常有趣和实用的工具。过去各种 CLI 工具分散在各处，而 x-cmd 则提供了一个全新的思路，不仅是简单的整合，而是深度的增强。作为一名开发者，我使用过各种桌面端工具箱提升效率，x-cmd 的出现则填补了终端没有高效工具箱的空白。在 AI 时代，x-cmd 集成如此多的工具也许会给人们更多的惊喜。 |
| **[黄盛明](https://github.com/adrianhsm)** | 技术 VP / 新能源方向总架构师 / 高级系统架构师 | 作为架构师，X-CMD 最让我惊艳的是它“架构级适配业务”的效率赋能——无需在工具链重构上浪费精力，就能快速搭建贴合架构设计需求的工作流。 |
| **[飞乐鸟](https://mp.weixin.qq.com/s/oxifrnyjwnKtNr3-DL2VFg)** | 高级 Java 开发工程师 / CSDN 认证技术博主 / 开源爱好者 | 这是一款轻量高效的命令行工具箱。它将包管理、环境配置与快捷指令完美集成，让终端操作变得行云流水，开发效率瞬间翻倍。 |
| **[王力](https://github.com/amslime)** | 首席算法工程师 / NOIP 评委 / ACM-ICPC 金牌 | 用久了才发现，X-CMD 真正省的是「脑力」。很多以前要记的 alias、脚本片段，都变成结构化模块和命令提示了，我现在更专注在解决问题本身，而不是回忆那句诡异的 one-liner。 |
| **[程序员晚枫](https://space.bilibili.com/259649365)** | 全网粉丝 30 万 / python-office 作者 / 白开水 AI 社区联创 | X-CMD 是一款神奇的命令行工具，其模块化设计和快捷调用方式与我们的开发思路完美契合。只需一句简单的命令，即可调用丰富功能。强烈推荐给所有追求高效工作的开发者。 |
| **[刘翯齐](https://github.com/Metaphorme)** | 致力于人工智能辅助疫苗设计 / 中国药科大学 | X-CMD是一个设计严谨、支持平台广、新手友好的模块化命令行工具集，安装和集成过程几乎透明，让用户可以专注于解决问题本身而不是环境配置。得益于其对大量开源CLI工具的统一封装与快速适配，社区中新出现的优秀项目往往能在较短时间内以模块或包的形式被纳入工作流之中，同时保持相对一致的使用体验与文档质量（尤其是对每个工具都有详细的文档与视频教程）。与核心开发者沟通的渠道简洁高效，反馈能够在迭代中得到及时而正向的回应，这与项目始终强调的开放、包容并深度依托开源生态的开发理念高度一致。我对它的长期演进充满信心。 |
| **Nxcode** | nxcode.io | 想让你的 AI 从‘只会聊天’变成‘真能干活’的工程师？用 X-CMD 就对了，它把最难搞的系统操作全包圆了。 |
| **[终南山葫芦娃](https://infmax.top)** | UCAS-ICT / 互联网高级工程师 / iTrending.top 作者 | 第一次接触 x-cmd 就被它深深吸引：它真正做到了效率与美感并存，大幅简化并规范了终端工具的部署流程。在 AI 时代，x-cmd 更是焕发出新的生命力。作为一名终端爱好者，衷心希望 x-cmd 越来越强大。 |
| **[王子伯炎](https://x.com/ssslvky)** | MemoV 创始人 | agent 时代最需要的 shell expert！超小体积可以最快分发的 shell-use，同时可以让你的 agent 以最快的速度完成任务。 |
| **[一面千识](https://talent.meetchances.com/jobs?_fr=xcmd)** | meetchances.com | 随着 AI Coding 的兴起，时代的齿轮再次回到 Terminal。X-CMD 帮助一面千识平台上的专家们高效解决环境配置与工具链问题，大幅提升研发与交付效率。强烈推荐给各位行业专家——早用上 X-CMD，早下班。 |
| **[华平玻纤](https://huaping-fiberglass.com/)** | huaping-fiberglass.com | 衷心感谢 X-CMD 团队的指导！我们运维团队已率先在内部测试中采用 x-cmd 和 x-cmd hub，成功实现了 prompt 和脚本的共享。我们尤其期待其在 CI/CD 和日常工作流中整合 AI Agent 和 Skill 的巨大潜力。 在 AI 时代，这种能力的重要性不言而喻，它将带来无限的联想和可能。祝愿 X-CMD 能够在 AI 时代大放异彩！ |
| **[Nick Young](https://github.com/Nick2bad4u)** | TDS Consulting 资深系统/网络工程师 | 我曾习惯用 Dropbox 同步便携版工具以切换不同电脑。现在，x-cmd 完全取代了这个方案——它本质上是一个巨大的工具箱，涵盖了我几乎所有的应用需求。相比手动配置，使用 x-cmd 显然更快速、更便捷。 |
| **[Marek Küthe](https://mk16.de/)** | 开源爱好者 | 我对 x-cmd 印象最深的一点，一方面是它出色的文档，其中既包含了使用示例，也有详细的参考指南；另一方面则是它优秀的视觉呈现。此外，它不会给人带来“强迫感”，而是给予了用户极大的自由度。 |
| **[Cierra Runis](https://note-of-me.top/)** | 开源爱好者 | x-cmd 将常见的系统与网络操作封装为更安全、易用的命令，并通过交互式设计降低了命令行的使用与记忆成本；同时，基于 Shell 的实现避免了额外运行时和依赖管理，真正做到即开即用、务实可靠。 |
| **吴濠棉** | 优秀物理教师 / 教育科技创新者 | 物理学探索宇宙规律，x-cmd 则诠释了数字世界的极简逻辑。其优雅的交互与 AI 辅助，让非计算机专业的师生也能轻松驾驭终端，极大地提升了备课与演示效率，是教育数字化转型的得力助手。 |
