# Pale Coins 简体中文汉化 —— 格式自检脚本
# Validates the zh pack's structural integrity. Run before opening a PR:
#   powershell -ExecutionPolicy Bypass -File tools\validate.ps1
#
# Self-contained: every file carries its own English source column, so no
# reference copy of the game is needed.

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName Microsoft.VisualBasic

$root = Split-Path -Parent $PSScriptRoot
$zh   = Join-Path $root 'lang\localization\zh'
if (-not (Test-Path $zh)) { Write-Error "找不到 $zh"; exit 1 }

function Parse-Csv([string]$path) {
    $p = New-Object Microsoft.VisualBasic.FileIO.TextFieldParser($path, [System.Text.Encoding]::UTF8)
    $p.TextFieldType = [Microsoft.VisualBasic.FileIO.FieldType]::Delimited
    $p.SetDelimiters(","); $p.HasFieldsEnclosedInQuotes = $true
    $rows = New-Object System.Collections.Generic.List[object]
    try { while (-not $p.EndOfData) { $rows.Add($p.ReadFields()) } } finally { $p.Close() }
    ,$rows
}

$problems = New-Object System.Collections.Generic.List[string]
$stats = @{ files = 0; rows = 0; translated = 0 }

function Check-File([string]$path, [int]$srcIdx, [int]$zhIdx, [int]$cols) {
    $name = Split-Path $path -Leaf
    $stats.files++

    # UTF-8 must not have a BOM
    $head = [byte[]](Get-Content -Path $path -Encoding Byte -TotalCount 3 -ErrorAction SilentlyContinue)
    if ($head.Count -ge 3 -and $head[0] -eq 0xEF -and $head[1] -eq 0xBB -and $head[2] -eq 0xBF) {
        $problems.Add("[BOM] $name 带有 UTF-8 BOM，请另存为无 BOM")
    }

    try { $rows = Parse-Csv $path }
    catch { $problems.Add("[解析失败] $name : $($_.Exception.Message)"); return }

    for ($i = 1; $i -lt $rows.Count; $i++) {
        $r = $rows[$i]
        $line = $i + 1
        if ($r.Count -ne $cols) {
            $problems.Add("[列数] $name 第 $line 行有 $($r.Count) 列，应为 $cols —— 多半是引号或逗号没转义")
            continue
        }
        $src = $r[$srcIdx]; $dst = $r[$zhIdx]
        $stats.rows++
        if ([string]::IsNullOrEmpty($src)) { continue }

        if ([string]::IsNullOrEmpty($dst)) {
            $problems.Add("[漏译] $name 第 $line 行 zh 列为空")
            continue
        }
        if ($dst -match '[一-鿿]') { $stats.translated++ }

        # #args:{...} suffix must survive byte-identical
        if ($src -match '#args:') {
            $suffix = $src.Substring($src.IndexOf('#args:'))
            if (-not $dst.EndsWith($suffix)) {
                $problems.Add("[#args] $name 第 $line 行的 #args 后缀被改动或丢失")
            }
        }
        # #placeholder tokens must all still be present.
        # Strip the known markup first, otherwise an ordinary word right after a
        # closing #text.default# tag looks like a "#word" placeholder.
        function Strip-Markup([string]$s) {
            $s = [regex]::Replace($s, '#args:.*$', '')
            $s = [regex]::Replace($s, '###[A-Za-z0-9_.]+###', '')
            $s = [regex]::Replace($s, '#text\.[^#]*#', '')
            $s = [regex]::Replace($s, '#:.*?:#', '')
            return $s
        }
        $srcBare = Strip-Markup $src
        $dstBare = Strip-Markup $dst
        foreach ($tok in ([regex]::Matches($srcBare, '#[a-z_]{3,}') | ForEach-Object { $_.Value } | Select-Object -Unique)) {
            if ($dstBare -notlike "*$tok*") {
                $problems.Add("[占位符] $name 第 $line 行缺少 $tok")
            }
        }
        # ###input.X### / ###player.name### markers
        foreach ($tok in ([regex]::Matches($src, '###[A-Za-z0-9_.]+###') | ForEach-Object { $_.Value } | Select-Object -Unique)) {
            if ($dst -notlike "*$tok*") { $problems.Add("[变量] $name 第 $line 行缺少 $tok") }
        }
        # #:...:# highlight markers must stay balanced
        $sm = ([regex]::Matches($src, '#:')).Count
        $dm = ([regex]::Matches($dst, '#:')).Count
        if ($sm -ne $dm) { $problems.Add("[高亮标记] $name 第 $line 行 #:...:# 数量不一致（原文 $sm，译文 $dm）") }
    }
}

foreach ($n in 'Language.csv','Items.csv','Quests.csv') {
    $p = Join-Path $zh $n
    if (Test-Path $p) { Check-File $p 1 3 4 } else { $problems.Add("[缺失] 找不到 $n") }
}
foreach ($f in Get-ChildItem (Join-Path $zh 'dialogues') -Filter *.csv) {
    Check-File $f.FullName 2 3 4
}

Write-Host ""
Write-Host ("检查文件 $($stats.files) 个，文本行 $($stats.rows) 行，其中含中文 $($stats.translated) 行。")
if ($problems.Count -eq 0) {
    Write-Host "✅ 未发现格式问题。" -ForegroundColor Green
    exit 0
} else {
    Write-Host "❌ 发现 $($problems.Count) 处问题：" -ForegroundColor Red
    $problems | Select-Object -First 100 | ForEach-Object { Write-Host "   $_" }
    if ($problems.Count -gt 100) { Write-Host "   ... 其余 $($problems.Count - 100) 处已省略" }
    exit 1
}
