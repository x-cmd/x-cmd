# 你好 | Nihao  -- 欢迎使用, 以下是入门信息

## 关于 x-cmd 模块 (mod)

x-cmd 的功能被组织成 shell 模块 (mod)。以 `path` 模块为例：

- `x path`            # 一个 TUI 应用，用于导航 PATH 中定义的文件夹及其文件。
- `x path -h`         # 显示 `path` 模块的帮助信息。请注意详细描述之前的 TLDR 示例。

我们努力保持一致的设计，以提高命令的可用性。一旦你熟悉了一个命令，就可以轻松地将这种知识和习惯应用到类似的命令中。
我们提供模块的快速搜索：                    https://x-cmd.com/mod
你可以轻松查看文档和教程：                  https://x-cmd.com/mod/<mod_name>

## 使用 x-cmd 包管理工具 `x env`

x-cmd 自带一个包管理工具，以按需下载常用的 CLI 工具，无需 root 权限。以 `jq` 为例：

- `x env use jq`    # 按需下载, 并在所有激活 x-cmd 的 shell 会话使用 jq
- `x env try jq`    # 按需下载, 仅在当前 shell 会话中使用 jq
- `x jq`            # 按需下载, 并直接调用 jq 二进制，该模式不会更改 PATH 或将 jq 二进制文件引入 /bin 类文件夹以避免影响环境。

关于 pkg 详情, 欢迎访问：                  https://x-cmd.com/pkg
通过 `x install` 查看应用的更多安装方法：  https://x-cmd.com/install

## AI 与云服务 CLI 模块

- `x openai init`     # 设置 API 密钥
- `@gpt3`             # 打开一个对话会话。
- `@gpt3 introduce yq command`

请注意，我们还提供 gemini、deepseek、kimi 等 LLM 模块, 以及 gh, cb, shodan, bwh 等网络服务 CLI 模块。

## 请活用我们的网页, 这是强交互的帮助文档应用

请注意，我们将模块和包分组到不同的类别中。请查看网页上的左侧面板。你可能会发现一些有趣的替代方案。
请为 x-cmd 加星并与你的好友分享            https://github.com/x-cmd/x-cmd
