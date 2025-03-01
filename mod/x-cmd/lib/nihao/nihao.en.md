# Hello | Nihao

Welcome to x-cmd. Here are a few things you might want to know to get started.

## About x-cmd mod

x-cmd functions are orgainized into modules (mod). Take path `mod` module for example:

- `x path`            # A TUI app to navigate folders defined in PATH and their files.
- `x path -h`         # Show help about the `path` module. Notice the TLDR examples before the detailed description.

We strive for consistent design to improve command usability. Once you're familiar with one command, that knowledge and habit can be easily applied to similar commands.

We provide a quick search of modules at         https://x-cmd.com/mod
You can easily view docs and tutorials at       https://x-cmd.com/mod/<mod_name>

## Using x-cmd pkg with `x env`

x-cmd comes with a pkg mangement tool to download common tools for CLI scenairo without root priviledge.
You can use the pkg system with a mod called `env`. Take `jq` for example:

- `x env use jq`    # Then you can use jq
- `x env try jq`    # You can only use jq in the current shell session
- `x jq`            # Use jq directly, however we won't influence the environment by changing the PATH or introducing jq binary to folder.

We provide a quick search of pkg in             https://x-cmd.com/pkg
You can easily view docs and tutorial in        https://x-cmd.com/pkg/<pkg_name>

**For more installation methods: `x pixi`, `x install`, etc**

Use pixi, asdf, etc. at ease                    https://x-cmd.com/mod/pixi
Browse more method with `x install`             https://x-cmd.com/install

## AI and aliases

- `x openai init`     # Setup the API keys
- `x openai -h`       # Help is helpful
- `@gpt3 introduce yq command`
- `@gpt3`             # Open a conversation session.

As usual, check out the docs on the website              https://x-cmd.com/mod/openai

Note, we also provide gemini, deepseek, kimi, ...

## Miscellaneous

Note that we group modules and packages into categories. Please check out the left panel on the webpage.
You might find some interesting alternatives.

X-CMD is still under development.

Please star x-cmd and share it with your friends       https://github.com/x-cmd
