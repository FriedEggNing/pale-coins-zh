
<#
  Pale Coins 简体中文汉化 —— 卸载脚本
  还原字体、删除汉化文件、把语言改回英文。
#>
param([string]$GamePath)

$ErrorActionPreference = 'Stop'

function Say([string]$m, [string]$c = 'Gray') { Write-Host $m -ForegroundColor $c }

Say ""
Say "  Pale Coins 简体中文汉化 —— 卸载程序" Cyan
Say "  ====================================" Cyan
Say ""

function Find-Game {
    $candidates = @()
    try {
        $steam = (Get-ItemProperty 'HKCU:\Software\Valve\Steam' -ErrorAction Stop).SteamPath
        if ($steam) {
            $steam = $steam -replace '/', '\'
            $candidates += Join-Path $steam 'steamapps\common\Pale Coins'
            $vdf = Join-Path $steam 'steamapps\libraryfolders.vdf'
            if (Test-Path $vdf) {
                foreach ($m in [regex]::Matches((Get-Content $vdf -Raw), '"path"\s*"([^"]+)"')) {
                    $p = $m.Groups[1].Value -replace '\\\\', '\'
                    $candidates += Join-Path $p 'steamapps\common\Pale Coins'
                }
            }
        }
    } catch { }
    foreach ($d in @('C','D','E','F','G','H')) {
        $candidates += "${d}:\Steam\steamapps\common\Pale Coins"
        $candidates += "${d}:\SteamLibrary\steamapps\common\Pale Coins"
    }
    foreach ($c in ($candidates | Select-Object -Unique)) {
        if (Test-Path (Join-Path $c 'Pale Coins.exe')) { return $c }
    }
    return $null
}

if (-not $GamePath) { $GamePath = Find-Game }
if (-not $GamePath -or -not (Test-Path (Join-Path $GamePath 'Pale Coins.exe'))) {
    Say "  找不到游戏目录，请用 -GamePath 指定。" Red
    Read-Host "  按回车退出"
    exit 1
}
Say "  游戏目录： $GamePath" Green

if (Get-Process -Name 'Pale Coins' -ErrorAction SilentlyContinue) {
    Say "  请先关闭游戏。" Red
    Read-Host "  按回车退出"
    exit 1
}

# 还原字体
$backup = Join-Path $GamePath '_zh_backup'
$restored = 0
foreach ($f in @('PixelFont.ttf', 'pixelplay.ttf')) {
    $bak = Join-Path $backup $f
    if (Test-Path $bak) { Copy-Item $bak (Join-Path $GamePath $f) -Force; $restored++ }
}
if ($restored -gt 0) {
    Say "  已还原 $restored 个原版字体" Green
} else {
    Say "  没找到字体备份。可以在 Steam 里「验证游戏文件完整性」来还原。" Yellow
}

# 删除汉化文件
$dstPack = Join-Path $GamePath 'lang\localization\zh'
if (Test-Path $dstPack) { Remove-Item $dstPack -Recurse -Force; Say "  已删除汉化文件" Green }

# 语言改回英文
$cfg = Join-Path $env:LOCALAPPDATA 'Pale_Coins\settings.json'
if (Test-Path $cfg) {
    $enc = New-Object System.Text.UTF8Encoding($false)
    $t = [IO.File]::ReadAllText($cfg, $enc)
    $t = [regex]::Replace($t, '"gameplay_language"\s*:\s*"[a-z\-]+"', '"gameplay_language":"en"')
    [IO.File]::WriteAllText($cfg, $t, $enc)
    Say "  已把语言改回英文" Green
}

Say ""
Say "  卸载完成。" Green
Say "  （$backup 里还留着原版字体备份，可以自行删除。）" Gray
Say ""
Read-Host "  按回车退出"
