# CLAUDE.md

本文件为 Claude Code (claude.ai/code) 在此代码仓库中工作时提供指导。

## 项目概述

这是一个 **流放之路 2 (POE2) 0.4赛季物品过滤器**仓库。提供专业的物品过滤系统，包含自定义声音提示、视觉特效以及 Windows 11 自动安装脚本。

**核心架构：**
- 物品过滤器文件（`.filter`）使用 POE2 官方过滤语法
- 自定义音频文件按类别组织在 `sounds/` 目录下
- 参考文档映射：简体中文名 → 英文 BaseType → 声音文件
- 自动化 PowerShell 脚本创建符号链接到 POE2 过滤器目录

## 关键数据源要求

**所有物品的 BaseType 名称必须从以下来源验证：**
- 简体中文：https://poe2db.tw/cn/
- 英文：https://poe2db.tw/us/

**严禁自行翻译或猜测 BaseType 名称。** 始终先查询官方数据库。这很关键，因为：
- POE2 使用与 POE1 不同的术语
- 直接翻译会导致过滤规则无法匹配物品
- 示例：POE2 中的 "Artificer's Orb" = "巧匠石"（不是"工匠石"）

## 文件命名规范

- **过滤器文件**：`poe2-<版本号>.filter`（例如 `poe2-0.4.filter`）
- **声音文件**：`<简体中文名>.mp3`，仅使用简体中文
- **文档**：使用描述性中文名称（例如 `物品对照表.md`、`物品视觉样式.md`）

## 物品价值等级系统（6级）

所有物品必须明确归入以下等级之一：

| 等级 | 价值 | 视觉样式 | 字体 | 音效音量 | 地图图标 |
|------|-------|--------------|------|--------------|----------|
| **S** | 顶级价值 | 金色 (255,215,0) | 45 (最大) | 300 (最大) | Size 2 星形 |
| **A** | 高价值 | 橙色 (255,165,0) | 40 (大) | 250 (清晰) | Size 1-2 菱形 |
| **B** | 中高价值 | 蓝色 (0,191,255) | 35 (标准) | 200 (弱提示) | Size 1 圆形 |
| **C** | 中等价值 | 绿色 (50,205,50) | 30 (小) | 150 (极弱) | 无 |
| **D** | 低价值 | 灰色 (105,105,105) | 25 (最小) | 无 | 无 |
| **E** | 无价值 | 隐藏 | - | - | - |

**不得**新增或合并等级 - 这是权威的6级系统。

## 过滤器文件结构

```filter
# 注释块，包含等级信息
Show
    Class "<类别名>"
    BaseType "<英文 BaseType>"
    Rarity <Normal/Magic/Rare/Unique>
    DropLevel <数字>
    ItemLevel <数字>
    SetBorderColor <R> <G> <B> <Alpha>
    SetBackgroundColor <R> <G> <B> <Alpha>
    SetTextColor <R> <G> <B> <Alpha>
    SetFontSize <1-45>
    MinimapIcon <0-2> <颜色> <形状>
    PlayEffect <颜色> <Temp>
    CustomAlertSound "sounds/<简体中文名>.mp3" <0-300>
```

**关键点：**
- `BaseType` 必须是来自 poe2db.tw 的英文名
- 声音文件路径使用简体中文名
- RGB 值：0-255，Alpha：0-255
- 多个条件 = AND 关系（必须全部满足）
- 每个规则块之间用空行分隔

## 声音文件组织

```
sounds/
├── 混沌石.mp3
├── 神圣石.mp3
├── 传奇项链.mp3
└── ...
```

**规则：**
- 声音文件必须是 MP3 格式
- 文件名必须使用简体中文
- 所有文件直接放在 sounds/ 根目录下
- 过滤器中的相对路径：`sounds/文件名.mp3`

## 文档文件

### docs/物品对照表.md
中央参考映射：
- 简体中文 → BaseType → 声音文件 → 价值等级

### docs/物品视觉样式.md
完整视觉规范：
- RGB 颜色、字体大小、图标尺寸
- 各等级的音效音量
- 特殊物品规则（腐化、未鉴定、影响之力）

### sounds/README.md
目录结构和声音设计指南

## 安装脚本架构

**文件：**
- `install.bat` - 启动器（调用 PowerShell 脚本）
- `install-en.ps1` - 主安装脚本（英文界面，避免编码问题）

**工作原理：**
1. 检测 POE2 安装路径：`%USERPROFILE%\Documents\My Games\Path of Exile 2\`
2. 查找当前目录的所有 `.filter` 文件
3. 检测 `sounds/` 目录
4. 创建符号链接（非复制）到目标目录
5. 如果文件存在则提示用户（回车=替换，ESC=取消）

**要求：**
- Windows 11
- 管理员权限 或 开发者模式已启用
- POE2 安装在默认位置

**关键 PowerShell 函数：**
```powershell
New-Item -ItemType SymbolicLink -Path $target -Value $source
```

## 更新物品或添加新功能

### 步骤1：从 poe2db.tw 验证
```bash
# 始终先检查 BaseType
# 示例：添加"完美混沌石"
# 1. 访问 https://poe2db.tw/cn/
# 2. 搜索"完美混沌石"
# 3. 确认 BaseType 是 "Perfect Chaos Orb"
```

### 步骤2：原子性更新所有文件
添加/修改物品时，按顺序更新这些文件：
1. `poe2-0.4.filter` - 添加过滤规则
2. `docs/物品对照表.md` - 添加到参考表
3. `docs/物品视觉样式.md` - 添加到视觉规范
4. `sounds/README.md` - 添加到目录列表

### 步骤3：保持一致性
- 所有文件中使用相同的简体中文名
- 过滤器和参考表中使用相同的英文 BaseType
- 正确的等级分类
- 匹配的声音文件路径

## 常用 POE2 过滤器条件

```filter
# 基础条件
Class "<类别名>"
BaseType "<物品名称>"
Rarity <Normal/Magic/Rare/Unique>
ItemLevel <数字>
DropLevel <数字>

# 插槽相关
Sockets <数字> <R/G/B/A/D/W>
LinkedSockets <数字>

# POE2 特有条件
UnidentifiedItemTier <数字>
WaystoneTier <数字>
Corrupted <True/False>
Identified <True/False>
HasInfluence <Shaper/Elder/Crusader/Hunter/Redeemer/Warlord>
```

## 重要术语说明

### 正确翻译（已验证）
- Chaos Orb = 混沌石
- Divine Orb = 神圣石
- Exalted Orb = 崇高石
- Vaal Orb = 瓦尔宝珠（不是 "Vaal珠宝"）
- Regal Orb = 富豪石（不是 "改造石"）
- Orb of Alchemy = 点金石（不是 "强袭石"）
- Orb of Transmutation = 蜕变石（不是 "魔法石"）
- Orb of Chance = 机会石（不是 "机遇石"）
- Perfect Jeweller's Orb = 完美工匠石（用于技能宝石）

### 完美通货（S级）
- Perfect Chaos Orb = 完美混沌石
- Perfect Exalted Orb = 完美崇高石
- Perfect Regal Orb = 完美富豪石
- Perfect Orb of Augmentation = 完美增幅石
- Perfect Orb of Transmutation = 完美蜕变石
- Perfect Jeweller's Orb = 完美工匠石

## 测试过滤器

无自动化测试。需要手动测试：
1. 运行 `install.bat`
2. 启动 POE2
3. 在设置 → 物品过滤器中加载过滤器
4. 在游戏中用实际物品掉落测试
5. 验证视觉/音频提示正常工作

## Git 工作流

**应提交的文件：**
- `.filter` 文件
- 文档（`.md` 文件）
- 安装脚本（`.bat`、`.ps1`）
- 声音文件（如果不太大）

**应忽略的文件（参见 .gitignore）：**
- `*-custom.filter`、`*-backup.filter`（用户特定）
- 系统文件：`Thumbs.db`、`Desktop.ini`
- 编辑器配置：`.vscode/`、`.idea/`
- 大型声音文件（可选 - 如需要可在 .gitignore 中取消注释）

## 赛季更新

当新赛季 POE2 开始时：
1. 更新 `poe2-<新版本>.filter` 文件名中的版本号
2. 更新过滤器文件中的头部注释
3. 检查 poe2db.tw 是否有新物品/变更物品
4. 更新 `prompt.md` 中的赛季版本号
5. 根据新的 Meta 调整物品等级

## 语言和本地化

**仓库使用混合中英文：**
- 过滤器文件：英文语法、中文注释
- 文档：中文（面向中文 POE2 社区）
- 声音文件：简体中文名
- 代码/脚本：英文变量名、中文/英文 UI 字符串（安装脚本使用英文避免编码问题）

**原因：** 目标用户是中文 POE2 玩家，但过滤器语法需要来自官方数据库的英文 BaseType。

## 安装和编码问题解决方案

### 历史问题
在开发过程中遇到的主要编码问题：
1. **中文路径问题**：bat 文件包含中文路径时在某些环境下会出现编码错误
2. **PowerShell 脚本编码**：包含中文字符的 .ps1 文件在某些执行环境下可能出错

### 最终解决方案
- **安装启动器**：`install.bat`（纯 ASCII 字符）
- **主脚本**：`install-en.ps1`（纯英文 UI，避免编码问题）
- **备用脚本**：`安装过滤器.bat` 和 `安装过滤器.ps1`（保留但可能有问题）

### 推荐使用
**始终使用 `install.bat`** 进行安装，这是最稳定的版本。
