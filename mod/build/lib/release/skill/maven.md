---
name: Java Maven Release
description: |
  Java Maven 包构建与发布专家。
  当用户需要打包、发布 Java 包到 Maven Central 或 JitPack 时使用此 skill。
  支持：(1) 创建 Maven 项目，(2) 构建和测试，(3) 发布到 Maven Central。
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---

# Java Maven Release

Java Maven 包构建与发布专家。

## 官方文档

- [Maven Guides](https://maven.apache.org/guides/)
- [Publishing to Maven Central](https://central.sonatype.org/publish/publish-guide/)
- [JitPack Docs](https://jitpack.io/docs/)

---

## 核心命令

| 命令 | 说明 |
|------|------|
| `x-cmd release maven init <dir>` | 初始化 Maven 项目 |
| `x-cmd release maven build <dir>` | 构建和测试 |
| `x-cmd release maven upload <dir>` | 显示 Maven Central 发布指引 |

---

## AI 工作流指引

### 设计原则

1. **自动检测 → 批量展示 → 单次确认**
2. **自动修复**常见问题（依赖下载、编译错误）
3. **只在关键决策点询问**（创建前、发布前）

### 标准流程

**创建项目：**
```
→ 创建 pom.xml
→ 创建 src/main/java 结构
→ 填充基本元数据
```

**构建流程：**
```
→ mvn compile（编译）
→ mvn test（运行测试）
→ mvn package（打包）
```

**发布流程：**
```
→ 配置 settings.xml
→ mvn deploy（发布）
→ 或创建 GitHub Release（JitPack）
```

---

## pom.xml 模板

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project>
    <modelVersion>4.0.0</modelVersion>
    
    <groupId>com.example</groupId>
    <artifactId>package-name</artifactId>
    <version>0.1.0</version>
    <packaging>jar</packaging>
    
    <name>Package Name</name>
    <description>Package description</description>
    <url>https://github.com/username/package</url>
    
    <properties>
        <maven.compiler.source>11</maven.compiler.source>
        <maven.compiler.target>11</maven.compiler.target>
    </properties>
    
    <dependencies>
        <dependency>
            <groupId>org.junit.jupiter</groupId>
            <artifactId>junit-jupiter</artifactId>
            <version>5.10.0</version>
            <scope>test</scope>
        </dependency>
    </dependencies>
</project>
```

---

## 关键命令参考

```bash
# 开发
mvn compile                    # 编译
mvn test                       # 运行测试
mvn package                    # 打包 JAR
mvn clean                      # 清理

# 发布（Maven Central）
mvn clean deploy -DskipTests   # 发布
mvn release:prepare            # 准备发布
mvn release:perform            # 执行发布

# JitPack（GitHub Release）
git tag v0.1.0
git push origin v0.1.0
```

---

## Maven Central 要求

- 需要 Sonatype JIRA 账号
- groupId 必须是拥有的域名或 io.github.username
- 必须使用 GPG 签名
- 必须包含 sources 和 javadoc

---

## 常见错误处理

| 错误 | 原因 | 解决 |
|------|------|------|
| `401 Unauthorized` | 认证失败 | 检查 settings.xml 凭证 |
| `403 Forbidden` | groupId 未授权 | 创建 Sonatype ticket |
| `Missing artifact` | 依赖不存在 | 检查依赖坐标 |
| `Compilation error` | Java 语法错误 | 修复代码错误 |
