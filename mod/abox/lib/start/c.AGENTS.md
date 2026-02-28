You can use `doas apt update` and `doas apt install <pkg>` without password.

To preserve software across container recreations, use x-cmd or pixi to install in `/home/ai` (which is mapped to host):

```bash
. ~/.x-cmd.root/X       # Load x-cmd
x pkg search <tool>     # Search package
x pkg use <tool>        # Install tool
```

```bash
. ~/.x-cmd.root/X       # Load x-cmd
x pixi search <name>    # Search package
x pixi use <tool>       # Install tool (pixi will be installed automatically)
```
