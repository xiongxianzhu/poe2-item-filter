# 🎒 POE2 Item Filter

<div align="center">

> **为 Path of Exile 2 打造的专业级物品过滤系统**

[![License](https://img.shields.io/badge/License-MIT-blue.svg?style=flat-square)](LICENSE)
[![Version](https://img.shields.io/badge/POE2-Season_0.4-orange.svg?style=flat-square)](https://poe2db.tw/)
[![Platform](https://img.shields.io/badge/Platform-Windows_11-blue.svg?style=flat-square)](https://www.microsoft.com/windows)

[特性](#-特性) • [安装](#-快速开始) • [文档](#-文档系统) • [FAQ](#-常见问题)

</div>

---

## ✨ 特性

- 💎 **智能分级**：基于市场价值的 **6级** 物品价值体系
- 🎵 **听觉盛宴**：全自定义 MP3 音效支持，掉落即知
- 🌈 **视觉增强**：独特的光柱、边框与小地图图标，快速识别
- ⚡ **一键部署**：双击脚本即可完成安装，自动符号链接同步
- 🔄 **实时同步**：修改配置后游戏中即时生效，无需繁琐重装

## 🚀 快速开始

### 📥 安装

只需一步，即可自动完成配置：

> 双击运行项目根目录下的 **`install.bat`**
>
> *注：需要 Windows 11 及管理员权限*

### 🎮 使用

1. 启动 **Path of Exile 2**
2. 进入 `设置` -> `物品` -> `物品过滤器`
3. 选择 **`xx-0.4.filter`**

## 💎 价值体系

我们构建了清晰的价值层级，让你一目了然：

| 等级 | 价值定义 | 视觉表现 | 音效提示 | 小地图 |
|:---:|:---|:---|:---|:---:|
| **S** | 🏆 **顶级珍宝** | 烈焰橙色 + 最大字号 | 🚨 300% 音量 | ⭐ 大星形 |
| **A** | 💰 **高价值** | 浓郁亮金 + 大字号 | 🔔 250% 音量 | 💠 中菱形 |
| **B** | 💎 **中高价值** | 电光青蓝 + 标准字号 | 🎵 200% 音量 | 🔵 小圆形 |
| **C** | 🟢 **中等价值** | 荧光毒绿 + 小字号 | 🔉 150% 音量 | - |
| **D** | 🌑 **低价值** | 铁灰墨黑 + 最小字号 | 🔇 静音 | - |

## 📂 项目结构

```text
poe2-item-filter/
├── 📜 xx-0.4.filter        # 核心过滤器文件
├── 🔊 sounds/              # 音效库 (MP3)
├── 📖 docs/                # 详细文档
│   ├── 物品对照表.md
│   ├── 物品视觉样式.md
│   └── 安装说明.md
├── 🛠️ install.bat          # 一键安装脚本
└── 📄 README.md            # 项目说明
```

## 📚 文档系统

- [🔍 **物品对照表**](docs/物品对照表.md)：中英对照与分类速查
- [🎨 **视觉样式规范**](docs/物品视觉样式.md)：配色方案与显示参数详解
- [📖 **安装指南**](docs/安装说明.md)：详细安装步骤与故障排查
- [🔊 **声音指南**](sounds/README.md)：自定义音效说明

## ❓ 常见问题

<details>
<summary><b>Q: 安装脚本提示找不到游戏目录？</b></summary>
<br>
A: 请确保您已运行过游戏至少一次，且游戏安装在默认路径。
</details>

<details>
<summary><b>Q: 游戏中没有声音？</b></summary>
<br>
A: 请检查 <code>sounds</code> 目录下是否有对应的 MP3 文件，且文件名为简体中文。
</details>

<details>
<summary><b>Q: 修改了过滤器没有生效？</b></summary>
<br>
A: 由于使用了符号链接，修改直接生效。请在游戏中点击刷新图标或重新加载过滤器。
</details>

<details>
<summary><b>Q: 脚本执行已被禁用？</b></summary>
<br>
A: 以管理员身份打开 PowerShell，运行：<code>Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser</code>
</details>

---

<div align="center">

**Enjoy your looting in Wraeclast!** ⚔️
<br>
<sub>Data Source: <a href="https://poe2db.tw/">POE2DB</a> | Audio Source: <a href="https://www.aigei.com/">Aigei</a></sub>

</div>

