# POE2 物品过滤器安装脚本
# 创建符号链接到POE2游戏目录

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$ErrorActionPreference = "Stop"

$SourceDir = Split-Path -Parent $MyInvocation.MyCommand.Path

$Poe2FilterDir = Join-Path $env:USERPROFILE "Documents\My Games\Path of Exile 2"

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
Write-Info "  POE2 物品过滤器 - 安装脚本"
Write-Info "================================================"
Write-Output ""

if (-not (Test-Path $Poe2FilterDir)) {
    Write-Error "错误：未找到POE2游戏目录！"
    Write-Output "预期路径：$Poe2FilterDir"
    Write-Output ""
    Write-Warning "请确认："
    Write-Output "1. 已安装Path of Exile 2"
    Write-Output "2. 游戏至少运行过一次"
    Write-Output "3. 使用默认安装路径"
    Write-Output ""
    Read-Host "按回车键退出"
    exit 1
}

Write-Success "成功：找到POE2目录：$Poe2FilterDir"
Write-Output ""

$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Warning "警告：创建符号链接需要管理员权限"
    Write-Output ""
    Write-Info "请右键点击此脚本，选择'以管理员身份运行'"
    Write-Output ""
    Read-Host "按回车键退出"
    exit 1
}

$filterFiles = Get-ChildItem -Path $SourceDir -Filter "*.filter" -File

if ($filterFiles.Count -eq 0) {
    Write-Error "错误：当前目录中未找到.filter文件！"
    Write-Output "当前目录：$SourceDir"
    Write-Output ""
    Read-Host "按回车键退出"
    exit 1
}

Write-Success "成功：找到 $($filterFiles.Count) 个过滤器文件："
foreach ($file in $filterFiles) {
    Write-Output "  - $($file.Name)"
}
Write-Output ""

$soundsSourceDir = Join-Path $SourceDir "sounds"
$soundsTargetDir = Join-Path $Poe2FilterDir "sounds"

$soundsExists = Test-Path $soundsSourceDir
if ($soundsExists) {
    Write-Success "成功：找到sounds目录"
} else {
    Write-Warning "警告：未找到sounds目录（可选）"
}
Write-Output ""

Write-Info "即将执行以下操作："
Write-Output "目标目录：$Poe2FilterDir"
Write-Output ""

$needReplace = $false

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
    Write-Warning "注意：某些文件已存在并将被替换！"
    Write-Info "说明："
    Write-Output "  - 按[回车]确认并继续"
    Write-Output "  - 按[ESC]取消"
    Write-Output ""

    $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

    if ($key.VirtualKeyCode -eq 27) {
        Write-Warning "操作已取消！"
        Write-Output ""
        Read-Host "按回车键退出"
        exit 0
    }

    Write-Output ""
}

Write-Info "正在创建符号链接..."
Write-Output ""

foreach ($file in $filterFiles) {
    $targetPath = Join-Path $Poe2FilterDir $file.Name
    if (Test-Path $targetPath) {
        try {
            Remove-Item -Path $targetPath -Force -Recurse -ErrorAction Stop
            Write-Output "  成功：已删除 $($file.Name)" -ForegroundColor Gray
        } catch {
            Write-Error "  失败：无法删除 $($file.Name)"
            Write-Error "    $($_.Exception.Message)"
        }
    }
}

if ($soundsExists -and (Test-Path $soundsTargetDir)) {
    try {
        Remove-Item -Path $soundsTargetDir -Force -Recurse -ErrorAction Stop
        Write-Output "  成功：已删除 sounds\" -ForegroundColor Gray
    } catch {
        Write-Error "  失败：无法删除 sounds\"
        Write-Error "    $($_.Exception.Message)"
    }
}

Write-Output ""

$successCount = 0
$failCount = 0

foreach ($file in $filterFiles) {
    $sourcePath = $file.FullName
    $targetPath = Join-Path $Poe2FilterDir $file.Name

    try {
        New-Item -ItemType SymbolicLink -Path $targetPath -Value $sourcePath -Force | Out-Null
        Write-Success "  成功：$($file.Name)"
        $successCount++
    } catch {
        Write-Error "  失败：$($file.Name)"
        Write-Error "    $($_.Exception.Message)"
        $failCount++
    }
}

if ($soundsExists) {
    try {
        New-Item -ItemType SymbolicLink -Path $soundsTargetDir -Value $soundsSourceDir -Force | Out-Null
        Write-Success "  成功：sounds\"
        $successCount++
    } catch {
        Write-Error "  失败：sounds\"
        Write-Error "    $($_.Exception.Message)"
        $failCount++
    }
}

Write-Output ""
Write-Info "================================================"
if ($failCount -eq 0) {
    Write-Success "成功：安装完成！已创建 $successCount 个符号链接"
} else {
    Write-Warning "警告：安装完成，但有 $failCount 个错误"
    Write-Success "成功：$successCount 个"
    Write-Error "失败：$failCount 个"
}
Write-Info "================================================"
Write-Output ""

Write-Info "后续步骤："
Write-Output "1. 启动Path of Exile 2"
Write-Output "2. 进入游戏设置"
Write-Output "3. 选择'物品过滤器'"
Write-Output "4. 从列表中选择已安装的过滤器"
Write-Output ""

Write-Info "提示："
Write-Output "- 符号链接会自动同步此目录中的更改"
Write-Output "- 修改的过滤器会立即在游戏中生效"
Write-Output "- 要卸载，只需删除目标目录中的链接文件"
Write-Output ""

Read-Host "按回车键退出"