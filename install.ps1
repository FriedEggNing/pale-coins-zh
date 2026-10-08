
<#
  Pale Coins 简体中文汉化 —— 一键安装脚本（方法 A）
  用法：右键 → 使用 PowerShell 运行
        或：powershell -ExecutionPolicy Bypass -File install.ps1
        指定路径：... -File install.ps1 -GamePath "D:\Steam\steamapps\common\Pale Coins"

  做的事：备份原字体 → 复制汉化文件 → 替换字体 → 把语言设为 zh
  卸载请运行 uninstall.ps1
#>
param([string]$GamePath)

$ErrorActionPreference = 'Stop'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path

function Say([string]$m, [string]$c = 'Gray') { Write-Host $m -ForegroundColor $c }

Say ""
Say "  Pale Coins 简体中文汉化 —— 安装程序" Cyan
Say "  ====================================" Cyan
Say ""

# ---------- 1. 找到游戏目录 ----------
function Find-Game {
    $candidates = @()
    try {
        $steam = (Get-ItemProperty 'HKCU:\Software\Valve\Steam' -ErrorAction Stop).SteamPath
        if ($steam) {
            $steam = $steam -replace '/', '\'
            $candidates += ($steam.TrimEnd('\') + '\steamapps\common\Pale Coins')
            $vdf = ($steam.TrimEnd('\') + '\steamapps\libraryfolders.vdf')
            if (Test-Path $vdf) {
                foreach ($m in [regex]::Matches((Get-Content $vdf -Raw), '"path"\s*"([^"]+)"')) {
                    $p = $m.Groups[1].Value -replace '\\\\', '\'
                    $candidates += ($p.TrimEnd('\') + '\steamapps\common\Pale Coins')
                }
            }
        }
    } catch { }
    $drives = (Get-PSDrive -PSProvider FileSystem -ErrorAction SilentlyContinue).Name
    foreach ($d in $drives) {
        $candidates += "${d}:\Steam\steamapps\common\Pale Coins"
        $candidates += "${d}:\SteamLibrary\steamapps\common\Pale Coins"
    }
    foreach ($c in ($candidates | Select-Object -Unique)) {
        if (Test-Path ($c + '\Pale Coins.exe')) { return $c }
    }
    return $null
}

if (-not $GamePath) { $GamePath = Find-Game }
if (-not $GamePath) {
    Say "  没有自动找到游戏目录。" Yellow
    Say "  请在 Steam 里右键游戏 → 管理 → 浏览本地文件，" Gray
    Say "  把打开的那个文件夹路径复制过来（地址栏点一下就能复制）。" Gray
    Say ""
    $GamePath = (Read-Host "  请粘贴游戏目录路径").Trim().Trim('"').Trim()
    if (-not $GamePath) {
        Say "  没有输入路径，已取消。" Red
        Read-Host "  按回车退出"
        exit 1
    }
}
if (-not (Test-Path ($GamePath.TrimEnd('\') + '\Pale Coins.exe'))) {
    Say "  这个目录里没有 Pale Coins.exe：" Red
    Say "    $GamePath" Red
    Read-Host "  按回车退出"
    exit 1
}
Say "  游戏目录： $GamePath" Green

# 游戏正在运行的话先关掉
if (Get-Process -Name 'Pale Coins' -ErrorAction SilentlyContinue) {
    Say "  检测到游戏正在运行，请先关闭游戏再安装。" Red
    Read-Host "  按回车退出"
    exit 1
}

# ---------- 2. 检查汉化文件 ----------
$srcPack = Join-Path $here 'lang\localization\zh'
$srcFont = Join-Path $here 'fonts\fusion-pixel-12px-proportional-zh_hans.ttf'
foreach ($p in @($srcPack, $srcFont)) {
    if (-not (Test-Path $p)) {
        Say "  汉化包文件缺失：$p" Red
        Say "  请确认解压完整，且本脚本与 lang / fonts 文件夹放在一起。" Yellow
        Read-Host "  按回车退出"
        exit 1
    }
}

# ---------- 3. 备份原字体 ----------
$backup = Join-Path $GamePath '_zh_backup'
if (-not (Test-Path $backup)) { New-Item -ItemType Directory -Path $backup | Out-Null }
foreach ($f in @('PixelFont.ttf', 'pixelplay.ttf')) {
    $orig = Join-Path $GamePath $f
    $bak  = Join-Path $backup $f
    if ((Test-Path $orig) -and -not (Test-Path $bak)) {
        Copy-Item $orig $bak
        Say "  已备份 $f"
    } elseif (Test-Path $bak) {
        Say "  $f 的备份已存在，跳过（保留最早的原版备份）"
    }
}

# ---------- 4. 复制汉化文件 ----------
$dstPack = Join-Path $GamePath 'lang\localization\zh'
if (Test-Path $dstPack) { Remove-Item $dstPack -Recurse -Force }
$dstParent = Join-Path $GamePath 'lang\localization'
if (-not (Test-Path $dstParent)) { New-Item -ItemType Directory -Path $dstParent -Force | Out-Null }
Copy-Item $srcPack $dstPack -Recurse -Force
$n = (Get-ChildItem $dstPack -Recurse -File).Count
Say "  已复制汉化文件（$n 个）" Green

# ---------- 5. 替换字体 ----------
Copy-Item $srcFont (Join-Path $GamePath 'PixelFont.ttf') -Force
Copy-Item $srcFont (Join-Path $GamePath 'pixelplay.ttf') -Force
Say "  已替换字体（PixelFont.ttf / pixelplay.ttf）" Green

# ---------- 6. 设置语言 ----------
$cfg = Join-Path $env:LOCALAPPDATA 'Pale_Coins\settings.json'
if (Test-Path $cfg) {
    $enc = New-Object System.Text.UTF8Encoding($false)
    $t = [IO.File]::ReadAllText($cfg, $enc)
    if ($t -match '"gameplay_language"\s*:\s*"[a-z\-]+"') {
        $t = [regex]::Replace($t, '"gameplay_language"\s*:\s*"[a-z\-]+"', '"gameplay_language":"zh"')
        [IO.File]::WriteAllText($cfg, $t, $enc)
        Say "  已将语言设为中文" Green
    } else {
        Say "  settings.json 里没找到语言项，请手动添加 \"gameplay_language\":\"zh\"" Yellow
    }
} else {
    Say "  还没有 settings.json（游戏一次都没运行过）。" Yellow
    Say "  请先启动一次游戏再退出，然后重新运行本脚本。" Yellow
}

# ---------- 完成 ----------
Say ""
Say "  安装完成，可以启动游戏了。" Green
Say ""
Say "  ⚠ 两个已知问题（原版游戏没有中文选项导致的）：" Yellow
Say "     1. 不要在「游戏设置」里点「保存设置」，会把语言重置回英文。" Yellow
Say "        真点了也不要紧，重新运行本脚本即可恢复。" Yellow
Say "     2. 屏幕最底部那行操作提示会被裁掉一点，只是显示问题。" Yellow
Say ""
Say "  想彻底解决这两个问题，请参考 README 里的「方法 B」。" Gray
Say "  卸载请运行 uninstall.ps1" Gray
Say ""
Read-Host "  按回车退出"
