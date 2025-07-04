#! /bin/sh

USHO=/home/abc

PATH="$USHO/node_modules/.bin:$PATH"
PATH="$USHO/p/bin:$PATH"
PATH="$USHO/.cargo/bin:$USHO/go/bin:$USHO/.deno/bin:$USHO/.bun/bin:$USHO/.local/bin:$USHO/.x-cmd.root/bin:$USHO/.x-cmd.root/local/data/pkg/sphere/X/l/j/h/bin/:$PATH"
PATH="$USHO/.pixi/bin:$PATH"

export PATH

if [ $# -gt 0 ]; then
    "$@"
elif command -v bash 2>/dev/null; then
    bash
else
    sh
fi
