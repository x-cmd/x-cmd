
BEGIN {
    if (PRIORITY == "") {
        PRIORITY = "x,brew,apt,dnf,yum,apk,pacman," \
                   "winget,choco,scoop," \
                   "uv,pip,bun,npm,go,cargo," \
                   "curl,wget,eget," \
                   "pixi,pkgx,asdf"
    }
    n = split(PRIORITY, pri, ",")
}

{
    if ($0 == "") next
    avail[$0] = 1
}

END {
    for (i = 1; i <= n; i++) {
        if (pri[i] in avail) { print pri[i]; exit }
    }
}
