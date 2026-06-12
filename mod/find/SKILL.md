# find Prune 模式

**默认用 `-prune`，不用 filter。** Filter 让 find 进入目录；prune 直接跳过。

## 标准形式

```sh
find ROOT \( -name DIR1 -prune -o -name DIR2 -prune -o ... \) -o -print
```

末尾 `-o -print`（或其他动作）处理未匹配分支。

## 常用 prune 名（项目噪音）

```sh
node_modules .git .svn .hg dist build out target vendor Pods DerivedData
__pycache__ .venv .gradle .mvn .cache .tmp .DS_Store
```

隐藏目录：`-name '.*' ! -name . -prune`

## 路径精确 prune（名字太通用时）

```sh
find . \( -path '*/node_modules' -prune -o -path '*/.git' -prune \) -o -print
```

## 配合 find 表达式

```sh
# 跳过噪音，找 .ts 文件
find . \( -name node_modules -prune -o -name .git -prune \) -o -type f -name '*.ts' -print

# 跳过噪音，最近 7 天修改的文件
find . \( -name node_modules -prune \) -o -type f -mtime -7 -print
```

## 看被忽略目录的内部

用户问"`.git/HEAD` 里有什么"，而搜索会 prune 掉 `.git`：

```sh
# 直接定位
find .git -name '*.txt' -print

# 或从 prune 列表里去掉 .git
find . \( -name node_modules -prune \) -o -print
```

## 坑

- **通配符要加引号**：`-name '*.js'`，不是 `-name *.js`（shell 会展开）
- **必须有 `-prune`**：`-name X -prune`，不是只写 `-name X`
- **`-name` vs `-path`**：`-name` 匹配 basename，`-path` 匹配路径
- **`-o` 短路**：顺序重要，频率高的放前面

## 项目探索 recipe

```sh
find . -maxdepth 3 \
    \( -name node_modules -prune -o \
       -name .git -prune -o \
       -name dist -prune -o \
       -name build -prune -o \
       -name __pycache__ -prune -o \
       -name '.*' ! -name . -prune \) \
    -o -print
```

## 别重复造轮子

- `x find` — 自动排除常见噪音，默认 prune
- `x bfind` — BFS 逐层搜索（浅层优先）
- `man find` — 完整参考
