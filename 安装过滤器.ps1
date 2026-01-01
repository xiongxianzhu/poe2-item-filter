# POE2 过滤器软链接安装脚本
# 用于将当前目录的过滤器文件和声音文件链接到POE2游戏目录

# 错误时停止执行
$ErrorActionPreference = "Stop"

# 获取脚本所在目录（源目录）
$SourceDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# POE2 默认过滤器目录
$Poe2FilterDir = Join-Path $env:USERPROFILE "Documents\My Games\Path of Exile 2"

# 颜色输出函数
function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) {
        Write-Output $args
    }
    $host.UI.RawUI.ForegroundColor = $fc
}

function Write-Success { Write-ColorOutput Green @Args }
function Write-Warning { Write-ColorOutput Yellow @Args }
function Write-Error { Write-ColorOutput Red @Args }
function Write-Info { Write-ColorOutput Cyan @Args }

Write-Info "================================================"
Write-Info "  POE2 物品过滤器 - 一键安装脚本"
Write-Info "================================================"
Write-Output ""

# 检查POE2目录是否存在
if (-not (Test-Path $Poe2FilterDir)) {
    Write-Error "错误：未找到 POE2 游戏目录！"
    Write-Output "预期路径: $Poe2FilterDir"
    Write-Output ""
    Write-Warning "请确认："
    Write-Output "1. 已安装 Path of Exile 2"
    Write-Output "2. 游戏至少运行过一次"
    Write-Output "3. 使用的是默认安装路径"
    Write-Output ""
    pause
    exit 1
}

Write-Success "✓ 找到 POE2 游戏目录: $Poe2FilterDir"
Write-Output ""

# 检查是否有管理员权限（创建符号链接需要管理员权限或开发者模式）
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    # 检查是否启用了开发者模式
    try {
        $devMode = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -ErrorAction Stop
        if ($devMode.AllowDevelopmentWithoutDevLicense -ne 1) {
            Write-Warning "警告：创建符号链接需要以下条件之一："
            Write-Output "1. 管理员权限"
            Write-Output "2. Windows 开发者模式已启用"
            Write-Output ""
            Write-Info "启用开发者模式的方法："
            Write-Output "设置 > 更新和安全 > 开发者选项 > 开发者模式"
            Write-Output ""
            Write-Warning "如果没有权限，脚本可能无法创建符号链接。"
            Write-Output ""

            $response = Read-Host "是否继续尝试？(Y/N，默认N)"
            if ($response -ne "Y" -and $response -ne "y") {
                exit 1
            }
        }
    } catch {
        Write-Warning "警告：无法检测开发者模式状态"
        Write-Output "如果创建符号链接失败，请以管理员身份运行此脚本"
        Write-Output ""
    }
}

# 获取当前目录所有 .filter 文件
$filterFiles = Get-ChildItem -Path $SourceDir -Filter "*.filter" -File

if ($filterFiles.Count -eq 0) {
    Write-Error "错误：当前目录下没有找到 .filter 文件！"
    Write-Output "当前目录: $SourceDir"
    Write-Output ""
    pause
    exit 1
}

Write-Success "✓ 找到 $($filterFiles.Count) 个过滤器文件:"
foreach ($file in $filterFiles) {
    Write-Output "  - $($file.Name)"
}
Write-Output ""

# 检查 sounds 目录
$soundsSourceDir = Join-Path $SourceDir "sounds"
$soundsTargetDir = Join-Path $Poe2FilterDir "sounds"

$soundsExists = Test-Path $soundsSourceDir
if ($soundsExists) {
    Write-Success "✓ 找到 sounds 目录"
} else {
    Write-Warning "⚠ 未找到 sounds 目录（可选）"
}
Write-Output ""

# 显示将要执行的操作
Write-Info "即将执行以下操作:"
Write-Output "目标目录: $Poe2FilterDir"
Write-Output ""

$needReplace = $false

# 检查文件是否已存在
foreach ($file in $filterFiles) {
    $targetPath = Join-Path $Poe2FilterDir $file.Name
    if (Test-Path $targetPath) {
        Write-Warning "  [替换] $($file.Name)"
        $needReplace = $true
    } else {
        Write-Output "  [新建] $($file.Name)"
    }
}

if ($soundsExists) {
    if (Test-Path $soundsTargetDir) {
        Write-Warning "  [替换] sounds\"
        $needReplace = $true
    } else {
        Write-Output "  [新建] sounds\"
    }
}

Write-Output ""

if ($needReplace) {
    Write-Warning "注意：部分文件已存在，将被替换！"
    Write-Info "操作说明:"
    Write-Output "  - 按 [回车键] 确认并继续"
    Write-Output "  - 按 [ESC] 键取消操作"
    Write-Output ""

    # 等待用户按键
    $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

    # ESC键的虚拟键码是27
    if ($key.VirtualKeyCode -eq 27) {
        Write-Warning "操作已取消！"
        Write-Output ""
        pause
        exit 0
    }

    Write-Output ""
}

Write-Info "开始创建符号链接..."
Write-Output ""

# 删除已存在的文件/目录（如果需要替换）
foreach ($file in $filterFiles) {
    $targetPath = Join-Path $Poe2FilterDir $file.Name
    if (Test-Path $targetPath) {
        try {
            Remove-Item -Path $targetPath -Force -Recurse -ErrorAction Stop
            Write-Output "  ✓ 已删除: $($file.Name)" -ForegroundColor Gray
        } catch {
            Write-Error "  ✗ 删除失败: $($file.Name)"
            Write-Error "    $($_.Exception.Message)"
        }
    }
}

if ($soundsExists -and (Test-Path $soundsTargetDir)) {
    try {
        Remove-Item -Path $soundsTargetDir -Force -Recurse -ErrorAction Stop
        Write-Output "  ✓ 已删除: sounds\" -ForegroundColor Gray
    } catch {
        Write-Error "  ✗ 删除失败: sounds\"
        Write-Error "    $($_.Exception.Message)"
    }
}

Write-Output ""

# 创建符号链接
$successCount = 0
$failCount = 0

foreach ($file in $filterFiles) {
    $sourcePath = $file.FullName
    $targetPath = Join-Path $Poe2FilterDir $file.Name

    try {
        New-Item -ItemType SymbolicLink -Path $targetPath -Value $sourcePath -Force | Out-Null
        Write-Success "  ✓ $($file.Name)"
        $successCount++
    } catch {
        Write-Error "  ✗ $($file.Name)"
        Write-Error "    $($_.Exception.Message)"
        $failCount++
    }
}

# 创建 sounds 目录的符号链接
if ($soundsExists) {
    try {
        New-Item -ItemType SymbolicLink -Path $soundsTargetDir -Value $soundsSourceDir -Force | Out-Null
        Write-Success "  ✓ sounds\"
        $successCount++
    } catch {
        Write-Error "  ✗ sounds\"
        Write-Error "    $($_.Exception.Message)"
        $failCount++
    }
}

Write-Output ""
Write-Info "================================================"
if ($failCount -eq 0) {
    Write-Success "✓ 安装完成！共创建 $successCount 个符号链接"
} else {
    Write-Warning "⚠ 安装完成，但有 $failCount 个失败"
    Write-Success "✓ 成功: $successCount 个"
    Write-Error "✗ 失败: $failCount 个"
}
Write-Info "================================================"
Write-Output ""

Write-Info "下一步:"
Write-Output "1. 启动 Path of Exile 2"
Write-Output "2. 进入游戏设置"
Write-Output "3. 选择 '物品过滤器'"
Write-Output "4. 从列表中选择已安装的过滤器"
Write-Output ""

Write-Info "提示:"
Write-Output "- 符号链接会自动同步本目录的更新"
Write-Output "- 修改本目录的过滤器后，游戏中直接生效"
Write-Output "- 如需卸载，直接删除目标目录的链接文件即可"
Write-Output ""

pause
