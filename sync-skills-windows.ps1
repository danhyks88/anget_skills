<#
  Lien ket (symlink) skill trong repo nay toi Claude Code / Codex / Kilo Code,
  va chen skill BAT BUOC (vietnamese-short-answer) vao cau hinh chung.

  Dung tu file .bat, khong chay truc tiep neu khong can:
    powershell -NoProfile -ExecutionPolicy Bypass -File sync-skills-windows.ps1 -Targets Claude,Codex,Kilo

  Neu khong tao duoc symlink (thieu quyen Administrator / chua bat Developer Mode),
  script se COPY thay the va bao ro trong output.
#>

param(
    [string[]]$Targets = @('Claude', 'Codex', 'Kilo')
)

$ErrorActionPreference = 'Stop'
$Src = Split-Path -Parent $MyInvocation.MyCommand.Path

$dst = @{
    Claude = Join-Path $env:USERPROFILE '.claude\skills'
    Codex  = Join-Path $env:USERPROFILE '.agents\skills'
    Kilo   = Join-Path $env:USERPROFILE '.kilocode\skills'
}

function Link-OrCopy([string]$source, [string]$target) {
    if (Test-Path $target) { Remove-Item $target -Recurse -Force }
    try {
        New-Item -ItemType SymbolicLink -Path $target -Target $source -Force | Out-Null
        return 'symlink'
    } catch {
        Copy-Item -Path $source -Destination $target -Recurse -Force
        return 'copy'
    }
}

Write-Host ""
Write-Host "==== LIEN KET SKILLS (Windows) ===="
Write-Host "Source: $Src"
Write-Host "Targets: $($Targets -join ', ')"
Write-Host ""

$linkCount = 0
Get-ChildItem -Path $Src -Directory | ForEach-Object {
    $categoryDir = $_.FullName
    Get-ChildItem -Path $categoryDir -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        $skillDir = $_.FullName
        $skillName = $_.Name
        if (Test-Path (Join-Path $skillDir 'SKILL.md')) {
            Write-Host "  [$($(Split-Path $categoryDir -Leaf))] $skillName"
            foreach ($t in $Targets) {
                $dstRoot = $dst[$t]
                if (-not (Test-Path $dstRoot)) { New-Item -ItemType Directory -Path $dstRoot -Force | Out-Null }
                $mode = Link-OrCopy -source $skillDir -target (Join-Path $dstRoot $skillName)
                if ($mode -eq 'copy') {
                    Write-Host "    [$t] khong tao duoc symlink, da COPY thay the (chay Admin/bat Developer Mode de symlink)"
                }
            }
            $linkCount++
        }
    }
}

# ---- Skill bat buoc: vietnamese-short-answer ----

$skillFile = Join-Path $Src 'general\vietnamese-short-answer\SKILL.md'
$startMark = '<!-- MANDATORY_SKILLS_START -->'
$endMark   = '<!-- MANDATORY_SKILLS_END -->'

function Set-MandatoryBlock([string]$path, [string]$block) {
    $dir = Split-Path $path -Parent
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    if (-not (Test-Path $path)) { New-Item -ItemType File -Path $path -Force | Out-Null }
    $content = Get-Content -Raw -Path $path -ErrorAction SilentlyContinue
    if ([string]::IsNullOrEmpty($content)) { $content = '' }

    $startIdx = $content.IndexOf($startMark)
    $endIdx = $content.IndexOf($endMark)

    if ($startIdx -ge 0 -and $endIdx -ge $startIdx) {
        $before = $content.Substring(0, $startIdx)
        $after = $content.Substring($endIdx + $endMark.Length)
        $content = $before + $block + $after
    } else {
        $content = $content.TrimEnd() + "`n`n" + $block + "`n"
    }
    Set-Content -Path $path -Value $content -NoNewline
}

if (-not (Test-Path $skillFile)) {
    Write-Host ""
    Write-Host "[CANH BAO] Khong thay $skillFile, bo qua buoc chen skill bat buoc."
} else {
    Write-Host ""
    Write-Host "==== CHEN SKILL BAT BUOC VAO CAU HINH CHUNG ===="

    if ($Targets -contains 'Claude') {
        $claudeMd = Join-Path $env:USERPROFILE '.claude\CLAUDE.md'
        $claudeBlock = "$startMark`n## Skill bat buoc`n`n@$skillFile`n$endMark"
        Set-MandatoryBlock -path $claudeMd -block $claudeBlock
        Write-Host "  - Da cap nhat $claudeMd (dung @import, tu dong cap nhat khi sua SKILL.md)"
    }

    if ($Targets -contains 'Codex') {
        $codexMd = Join-Path $env:USERPROFILE '.codex\AGENTS.md'
        $raw = Get-Content -Raw -Path $skillFile
        $body = [regex]::Replace($raw, '(?s)^---.*?---\s*', '', 1)
        $codexBlock = "$startMark`n## Skill bat buoc: vietnamese-short-answer`n(Dong bo tu $skillFile - chay lai script nay sau khi sua file de cap nhat)`n`n$body`n$endMark"
        Set-MandatoryBlock -path $codexMd -block $codexBlock
        Write-Host "  - Da cap nhat $codexMd (nhung noi dung, can chay lai script khi SKILL.md doi)"
    }

    if ($Targets -contains 'Kilo') {
        $kiloMd = Join-Path $env:USERPROFILE '.config\kilo\AGENTS.md'
        $raw = Get-Content -Raw -Path $skillFile
        $body = [regex]::Replace($raw, '(?s)^---.*?---\s*', '', 1)
        $kiloBlock = "$startMark`n## Skill bat buoc: vietnamese-short-answer`n(Dong bo tu $skillFile - chay lai script nay sau khi sua file de cap nhat)`n`n$body`n$endMark"
        Set-MandatoryBlock -path $kiloMd -block $kiloBlock
        Write-Host "  - Da cap nhat $kiloMd (nhung noi dung, can chay lai script khi SKILL.md doi)"
    }
}

Write-Host ""
Write-Host "==== DONE ===="
Write-Host "So skill da lien ket: $linkCount"
Write-Host "Hay khoi dong lai VS Code / Kilo Code / Codex / Claude Code de nhan thay doi."
