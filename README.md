# [X-CMD](https://x-cmd.com/zh)

在云上 施展 弹指神通 ～

现在仍处于内测阶段: v0.1.0 版本

## Install

```bash
eval "$(curl https://get.x-cmd.com)"
```

```bash
eval "$(wget -O- https://get.x-cmd.com)"
```


## 已发布工具列表

| 模块  | 功能｜ 类似项目 |
| ---   | --- | --- ｜
| theme ｜设置shell的主题  | oh-my-zsh/oh-my-bash |
| env   ｜   | asdf/nvm/sdkman/pyenv/rbenv/... |
| tldr  ｜   | tldr客户端工具 |
| gh    ｜   | gh -- github client |
| gt    ｜   | gt -- gitee client |


## 介绍

1. 可在主流posix shell(bash/zsh/dash/ash，更多将在后续支持)系统环境下(即便在非scratch轻量容器镜像内，如busybox，alpine等镜像)，一键运行托管脚本
2. 可安装主流开发语言运行时（现支持node，python，java等等），在此之上，可让用户在装有x环境下的环境上一键运行托管脚本
3. 增强posix shell的用户体验：主题，路径快速跳转，后面会加入更好的shell智能补全和提示功能
4. 提供一系列的交互式cli工具（github, gitee，更多的工具模块将在最近半年发布）
5. 极轻极快: 安装包体积小于500KB，里面已经包括上述的功能模块
