---
name: Conda Release
description: |
  Conda 包构建与发布专家。
  当用户需要打包、发布 Conda 包到 conda-forge 或 Anaconda Cloud 时使用此 skill。
  支持：(1) 创建 Conda recipe，(2) 构建包，(3) 发布到 conda-forge。
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---

# Conda Release

Conda 包构建与发布专家。

## 官方文档

- [conda-forge docs](https://conda-forge.org/docs/)
- [Creating Conda packages](https://docs.conda.io/projects/conda-build/en/latest/user-guide/tutorials/build-pkgs.html)
- [Recipe reference](https://docs.conda.io/projects/conda-build/en/latest/resources/define-metadata.html)

---

## 核心命令

| 命令 | 说明 |
|------|------|
| `x-cmd release conda init <dir>` | 初始化 Conda recipe |
| `x-cmd release conda build <dir>` | 构建 Conda 包 |
| `x-cmd release conda upload <dir>` | 显示 conda-forge 发布指引 |

---

## AI 工作流指引

### 设计原则

1. **自动检测 → 批量展示 → 单次确认**
2. **自动修复**常见问题（依赖解析）
3. **只在关键决策点询问**（创建前、提交前）

### 标准流程

**创建 recipe：**
```
→ 创建 meta.yaml
→ 创建 build.sh（Unix）
→ 填充包元数据
```

**构建流程：**
```
→ 检查 meta.yaml 语法
→ conda-build .（构建包）
→ 测试安装
```

**发布流程：**
```
→ Fork staged-recipes
→ 提交 PR
→ 等待 review
```

---

## meta.yaml 模板

```yaml
{% set name = "package-name" %}
{% set version = "0.1.0" %}

package:
  name: {{ name|lower }}
  version: {{ version }}

source:
  url: https://pypi.io/packages/source/{{ name[0] }}/{{ name }}/{{ name }}-{{ version }}.tar.gz
  sha256: placeholder

build:
  number: 0
  noarch: python
  script: {{ PYTHON }} -m pip install . -vv

requirements:
  host:
    - python >=3.8
    - pip
  run:
    - python >=3.8

test:
  imports:
    - package_name

about:
  home: https://github.com/username/package
  summary: 'Package description'
  license: MIT

extra:
  recipe-maintainers:
    - your-github-username
```

---

## 关键命令参考

```bash
# 安装工具
conda install conda-build

# 构建
conda build .                  # 构建包
conda build --output .         # 查看输出路径

# 本地测试
conda install --use-local package-name

# 上传
anaconda upload /path/to/package.tar.bz2
```

---

## conda-forge 要求

- 必须有开源许可证
- 必须有明确的上游源码
- 必须包含测试（imports 或 commands）
- 推荐基于 PyPI 包

---

## 常见错误处理

| 错误 | 原因 | 解决 |
|------|------|------|
| `Jinja2 error` | 模板语法错误 | 检查 {{ }} 语法 |
| `SHA256 mismatch` | 校验和不匹配 | 重新计算 sha256 |
| `Missing dependency` | 缺少依赖 | 添加到 requirements |
