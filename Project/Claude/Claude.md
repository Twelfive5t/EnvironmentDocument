# Claude Code 配置指南

## 📋 目录

- [Claude Code 配置指南](#claude-code-配置指南)
  - [📋 目录](#-目录)
  - [简介](#简介)
  - [安装配置](#安装配置)
    - [1. 创建配置目录](#1-创建配置目录)
    - [2. 创建配置文件](#2-创建配置文件)
  - [API Key 配置](#api-key-配置)
  - [环境变量说明](#环境变量说明)
  - [常见问题](#常见问题)
    - [1. 如何获取 GLM API Key](#1-如何获取-glm-api-key)
    - [2. 配置不生效](#2-配置不生效)

---

## 简介

Claude Code 是 Anthropic 官方推出的 AI 编程助手 CLI 工具。

参考文档: <https://docs.newapi.pro/zh/docs/apps/claude-code>

---

## 安装配置

### 1. 创建配置目录

**Windows:**

```powershell
mkdir C:\Users\你的用户名\.claude
```

**Linux/macOS:**

```bash
mkdir -p ~/.claude
```

### 2. 创建配置文件

**Windows:**

```powershell
notepad C:\Users\你的用户名\.claude\settings.json
```

**Linux/macOS:**

```bash
vim ~/.claude/settings.json
```

---

## API Key 配置

将以下内容写入 `settings.json`，替换你的 GLM API Key：

```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://api.z.ai/api/anthropic",
    "ANTHROPIC_AUTH_TOKEN": "你的GLM_API_KEY",
    "API_TIMEOUT_MS": "3000000",
    "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "claude",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "claude",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "claude",
    "ANTHROPIC_MODEL": "claude"
  }
}
```

---

## 环境变量说明

| 变量名 | 说明 |
|-------- | ------ |
| `ANTHROPIC_BASE_URL` | API 服务地址 |
| `ANTHROPIC_AUTH_TOKEN` | API Key |
| `API_TIMEOUT_MS` | 请求超时时间（毫秒） |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` | 禁用非必要流量（设置为 1） |
| `ANTHROPIC_MODEL` | 默认模型名称 |

---

## 常见问题

### 1. 如何获取 GLM API Key

访问 GLM 平台注册并获取 API Key。

### 2. 配置不生效

- 确认配置文件路径正确
- 确认 JSON 格式无误
- 重启 Claude Code

---

**文档版本**: 1.0
**创建日期**: 2026-04-08
**维护人**: liuyijie
