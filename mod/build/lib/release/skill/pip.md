---
name: Python PIP Release
description: |
  Python pip 包构建与发布专家。
  当用户需要打包、发布 Python 包到 PyPI 时使用此 skill。
  支持：(1) 创建 Python 项目，(2) 构建 wheel/sdist，(3) 发布到 PyPI。
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---

# Python PIP Release

Python pip 包构建与 PyPI 发布专家。

## 官方文档

- [Python Packaging User Guide](https://packaging.python.org/)
- [pyproject.toml](https://packaging.python.org/en/latest/specifications/declaring-project-metadata/)
- [Publishing to PyPI](https://packaging.python.org/en/latest/tutorials/packaging-projects/)

---

## 核心命令

| 命令 | 说明 |
|------|------|
| `x-cmd release pip init <dir>` | 初始化 Python 项目 |
| `x-cmd release pip build <dir>` | 构建 wheel 和 sdist |
| `x-cmd release pip upload <dir>` | 显示 PyPI 发布指引 |

---

## AI 工作流指引

### 设计原则

1. **自动检测 → 批量展示 → 单次确认**
2. **自动修复**常见问题（依赖安装、权限）
3. **只在关键决策点询问**（创建前、发布前）

### 标准流程

**创建项目：**
```
→ 创建 pyproject.toml
→ 创建 src/package_name/__init__.py
→ 填充基本元数据
```

**构建流程：**
```
→ 安装 build 和 twine
→ python -m build（构建 wheel 和 sdist）
→ twine check dist/*（检查包）
```

**发布流程：**
```
→ 配置 PyPI token
→ python -m twine upload dist/*
```

---

## pyproject.toml 模板

```toml
[build-system]
requires = ["setuptools>=61.0", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "package-name"
version = "0.1.0"
description = "Package description"
readme = "README.md"
authors = [
    {name = "Your Name", email = "your@email.com"}
]
license = {text = "MIT"}
requires-python = ">=3.8"
classifiers = [
    "Programming Language :: Python :: 3",
    "License :: OSI Approved :: MIT License",
]
dependencies = []

[project.optional-dependencies]
dev = ["pytest>=7.0.0", "build>=0.8.0", "twine>=4.0.0"]

[project.urls]
Homepage = "https://github.com/username/package"
```

---

## 关键命令参考

```bash
# 安装工具
pip install build twine

# 构建
python -m build                 # 构建 wheel + sdist
python -m build --wheel         # 仅 wheel
python -m build --sdist         # 仅 sdist

# 检查
twine check dist/*              # 检查包完整性

# 上传
twine upload dist/*             # 上传到 PyPI
twine upload --repository testpypi dist/*  # 上传到 TestPyPI

# 本地安装测试
pip install dist/*.whl
```

---

## PyPI 要求

- 包名必须唯一（全局）
- 必须有 version 和 description
- 必须有 author 信息
- 建议包含：readme, license, classifiers
- 版本遵循 PEP 440

---

## 常见错误处理

| 错误 | 原因 | 解决 |
|------|------|------|
| `403 Forbidden` | 包名被占用或 token 无效 | 更换包名或检查 token |
| `400 Invalid` | 版本已存在 | 递增版本号 |
| `File too large` | 包超过大小限制 | 联系 PyPI 增加限制 |
| `README not found` | readme 文件不存在 | 创建 README.md |
