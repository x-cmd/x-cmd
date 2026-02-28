---
name: Fedora RPM Release
description: |
  Fedora/RHEL RPM 包构建与发布专家。
  当用户需要打包、发布 Fedora/RHEL/CentOS 软件包时使用此 skill。
  支持：(1) 创建 SPEC 文件，(2) 构建 .rpm 包，(3) 提交到 COPR 或官方仓库。
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---

# Fedora RPM Release

Fedora/RHEL RPM 包构建与发布专家。

## 官方文档

- [RPM Packaging Guide](https://docs.fedoraproject.org/en-US/packaging-guidelines/)
- [Creating RPM packages](https://docs.fedoraproject.org/en-US/quick-docs/creating-rpm-packages/)
- [COPR Documentation](https://docs.pagure.org/copr.copr/)

---

## 核心命令

| 命令 | 说明 |
|------|------|
| `x-cmd release rpm init <dir>` | 初始化 SPECS 目录 |
| `x-cmd release rpm build <dir>` | 构建 .rpm 包（本地）|
| `x-cmd release rpm build-docker <dir>` | 使用 Docker 构建 |
| `x-cmd release rpm upload <dir>` | 显示 COPR/官方仓库发布指引 |

---

## AI 工作流指引

### 设计原则

1. **自动检测 → 批量展示 → 单次确认**
2. **自动修复**常见问题（依赖安装、路径修正）
3. **只在关键决策点询问**（创建前、提交前）

### 标准流程

**创建 SPEC：**
```
→ 检测项目类型（Cargo.toml/go.mod/package.json 等）
→ 如存在 rpmdev-newspec，使用它生成模板
→ 否则使用内置模板
→ 创建 SOURCES/, SPECS/, BUILD/, RPMS/, SRPMS/ 结构
```

**构建流程：**
```
→ 检测本地 rpmbuild 是否可用
→ 运行 rpmlint 检查 SPEC
→ 自动安装 BuildRequires（dnf builddep）
→ 执行 rpmbuild
```

**发布流程：**
```
→ 检测 SRPM 文件
→ 如指定 --copr，使用 copr-cli 上传
→ 否则显示手动上传步骤
```

---

## SPEC 文件模板

```spec
Name:           package-name
Version:        1.0.0
Release:        1%{?dist}
Summary:        Package description

License:        MIT
URL:            https://example.com
Source0:        %{name}-%{version}.tar.gz

BuildRequires:  gcc, make
Requires:       some-dependency

%description
Package description

%prep
%autosetup

%build
%configure
make %{?_smp_mflags}

%install
make install DESTDIR=%{buildroot}

%files
%{_bindir}/your-command
%{_mandir}/man1/your-command.1.*

%changelog
* Mon Jan 01 2024 Your Name <your@email> - 1.0.0-1
- Initial package
```

---

## 关键命令参考

```bash
# 工具安装
dnf install rpmdevtools rpmlint

# SPEC 生成
rpmdev-newspec package.spec
rpmdev-newspec --type python package.spec   # Python 项目

# 构建
rpmbuild -ba SPECS/package.spec             # 构建二进制和源码包
rpmbuild -bb SPECS/package.spec             # 仅二进制包

# 依赖安装
dnf builddep SPECS/package.spec             # 安装构建依赖

# 检查
rpmlint SPECS/package.spec
rpmlint RPMS/x86_64/*.rpm

# COPR 发布
copr-cli build project-name package.src.rpm
```

---

## 常见错误处理

| 错误 | 原因 | 解决 |
|------|------|------|
| `rpmlint failed` | SPEC 文件有问题 | 根据 rpmlint 提示修正 |
| `BuildRequires not found` | 缺少构建依赖 | 运行 `dnf builddep` |
| `source not found` | 源码包路径错误 | 确认 Source0 路径 |
| `file not found` | %files 中列出的文件不存在 | 检查 %install 步骤 |
