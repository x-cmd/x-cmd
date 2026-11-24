# shellcheck shell=bash

(

git clone https://github.com/x-cmd/release || exit 1

cd release/stream || exit 1
release="$(x gh repo release ls)"

for v in *; do
    if release="$(echo "$release" | grep -F "$v" | head -n 1)"; then
        : TODO: existing release, check the commit
    else
        : TODO: not existing release, create it
    fi
done

)
