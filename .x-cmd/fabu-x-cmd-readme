# shellcheck shell=dash

f_sync(){
    local branch="$1"; shift
    local repo="x-cmd.$branch"
    local commit_id="$(git rev-parse HEAD)"
    git clone -b "$branch" git@github.com:x-cmd/x-cmd "$repo" || return
    (
        cd "$repo" || return
        cp "$@" ./
        git add .
        git commit -m "Updating main branch using x-cmd/x-cmd-readme -> $commit_id"

        git push origin "$branch"

        # TODO: replace with checkout branch "$branch" then `x ws sync`
        git push git@gitcode.net:x-cmd/x-cmd "$branch"
        git push git@gitee.com:x-cmd/x-cmd "$branch"
    )
}

git clone git@github.com:x-cmd/x-cmd-readme -b main
(
    cd x-cmd-readme

    # prepare data ... # generate demo
    f_sync X    "$PWD/README.cn.md" "$PWD/README.md"    || return
    # f_sync main "$PWD/README.cn.md" "$PWD/README.md"    || return
)
