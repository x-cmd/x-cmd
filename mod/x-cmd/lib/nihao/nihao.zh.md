# 你好 | Nihao

欢迎使用 x-cmd。这里有一些入门信息。

## 关于 x-cmd 模块 (mod)

x-cmd 的功能被组织成模块 (mod)。以 `path` 模块为例：

- `x path`            # 一个 TUI 应用，用于导航 PATH 中定义的文件夹及其文件。
- `x path -h`         # 显示 `path` 模块的帮助信息。请注意详细描述之前的 TLDR 示例。

我们努力保持一致的设计，以提高命令的可用性。一旦你熟悉了一个命令，就可以轻松地将这种知识和习惯应用到类似的命令中。

我们提供模块的快速搜索：         https://x-cmd.com/mod
你可以轻松查看文档和教程：       https://x-cmd.com/mod/<mod_name>

## 使用 x-cmd 包管理工具 `x env`

x-cmd 自带一个包管理工具，可以下载常用的 CLI 工具，无需 root 权限。
你可以使用名为 `env` 的模块来使用包系统。以 `jq` 为例：

- `x env use jq`    # 然后你可以使用 jq
- `x env try jq`    # 你只能在当前 shell 会话中使用 jq
- `x jq`            # 直接使用 jq，但是我们不会通过更改 PATH 或将 jq 二进制文件引入文件夹来影响环境。

我们提供包的快速搜索：             https://x-cmd.com/pkg
你可以轻松查看文档和教程：        https://x-cmd.com/pkg/<pkg_name>

**更多安装方法：`x pixi`，`x install` 等**

轻松使用 pixi、asdf 等：                    https://x-cmd.com/mod/pixi
使用 `x install` 查看更多方法：             https://x-cmd.com/install

## AI 和别名

- `x openai init`     # 设置 API 密钥
- `x openai -h`       # 帮助信息很有用
- `@gpt3 introduce yq command`
- `@gpt3`             # 打开一个对话会话。

像往常一样，请查看网站上的文档              https://x-cmd.com/mod/openai

请注意，我们还提供 gemini、deepseek、kimi 等。

## 其他

请注意，我们将模块和包分组到不同的类别中。请查看网页上的左侧面板。
你可能会发现一些有趣的替代方案。

X-CMD 仍在开发中。

请为 x-cmd 加星并与你的朋友分享       https://github.com/x-cmd
