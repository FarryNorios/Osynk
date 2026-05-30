# 📦 Osynk

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.11+-02569B?logo=flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/Platform-Android-3DDC84?logo=android&logoColor=white" alt="Android">
  <img src="https://img.shields.io/badge/Dart-3.11+-0175C2?logo=dart&logoColor=white" alt="Dart">
  <img src="https://img.shields.io/badge/License-Educational-orange" alt="License">
</p>

<p align="center">
  <b>中文</b> · <a href="./README_EN.md">English</a>
</p>

---

> ⚠️ **声明** — 本项目仅供学习和个人使用。开发者不对因使用本软件造成的任何数据丢失、账户问题或其他损害承担责任。使用本软件即表示您同意自行承担风险。
>
> 本项目与 Microsoft Corporation 无关，亦未获得其赞助或认可。OneDrive 是 Microsoft Corporation 的注册商标。

---

## 📖 介绍

Osynk 是一个 Android 平台的 OneDrive 文件同步工具，基于 Flutter 开发。

**🎯 本项目为学习目的创建**，用于实践 Flutter 状态管理、OAuth 认证流、文件 I/O、Graph API 集成等技术。

## ✨ 功能

- 🔐 Microsoft OneDrive OAuth 登录
- 📋 多任务同步管理（增删改查）
- 🔄 三种同步模式：双向同步 / 上传镜像 / 下载镜像
- 📊 同步进度实时显示（流式下载进度、速度、百分比）
- 📝 同步日志记录与查看
- 📁 本地/远程文件夹选择器
- 🎨 Material 3 主题，支持自定义主题色
- 🌐 中英文双语界面

## 🛠️ 开发

```bash
flutter pub get          # 📥 安装依赖
flutter run              # ▶️ 运行
flutter analyze          # 🔍 静态分析
flutter build apk        # 📦 构建 APK
```

## 📋 环境要求

| 依赖 | 版本 |
|------|------|
| 🐦 Flutter SDK | ≥ 3.11.0 |
| 🤖 Android minSdk | 33 (Android 13) |
| 🎯 Android targetSdk | 34 (Android 14) |

---

<p align="center">
  <sub>For educational use only / 仅供学习使用。</sub>
</p>
