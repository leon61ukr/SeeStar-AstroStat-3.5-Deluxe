# ==============================
# SeeStar AstroStat 3.5 Deluxe
# A smart PowerShell utility that analyzes astrophotography session data from SeeStar S50 (or similar FIT/FITS datasets).
# It automatically scans _sub and _mosaic_sub folders, counts total frames, exposure times, and failed captures — then outputs a clean, color-coded summary with per-object and global statistics.
# Color refinement + cleaner summary
# ==============================

Set-ExecutionPolicy -Scope Process Bypass -Force
[System.Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null

$root = Split-Path $MyInvocation.MyCommand.Path

# Regex patterns
$stackPattern  = "^Stacked_(\d+)_(?:.+?)_(\d+\.?\d*)s"
$lightPattern  = "(?:^|_)(\d+\.?\d*)s(?:_|$)"
$failedPattern = "_failed_"

# Containers
$globalData = @{}
$totalFailed = 0

Write-Host "`n=== SeeStar AstroStat 3.5 Deluxe ===`n" -ForegroundColor Cyan

# Collect only *_sub and *_mosaic_sub folders
$targetDirs = Get-ChildItem $root -Directory | Where-Object { $_.Name -match '(_sub$|_mosaic_sub$)' }

foreach ($dir in $targetDirs) {
    $folder = $dir.Name
    $path = $dir.FullName
    $baseName = ($folder -replace '_mosaic_sub$','' -replace '_sub$','')

    if (-not $globalData.ContainsKey($baseName)) {
        $globalData[$baseName] = @{
            sub = $null
            mosaic = $null
        }
    }

    # Collect data
    $data = @{
        Frames = 0
        Seconds = 0.0
        Failed = 0
        Exposures = @{}
    }

    Get-ChildItem $path -Filter *.fit | ForEach-Object {
        $file = $_.BaseName
        if ($file -match $stackPattern) {
            $frames = [int]$matches[1]
            $exp = [double]$matches[2]
            $data.Frames += $frames
            $data.Seconds += ($frames * $exp)
            if (-not $data.Exposures.ContainsKey($exp)) { $data.Exposures[$exp] = 0 }
            $data.Exposures[$exp] += $frames
        }
        elseif ($file -match $lightPattern) {
            $exp = [double]$matches[1]
            if ($file -match $failedPattern) {
                $data.Failed++
                $totalFailed++
            } else {
                $data.Frames++
                $data.Seconds += $exp
                if (-not $data.Exposures.ContainsKey($exp)) { $data.Exposures[$exp] = 0 }
                $data.Exposures[$exp]++
            }
        }
    }

    if ($folder -match '_mosaic_sub$') {
        $globalData[$baseName].mosaic = $data
    } else {
        $globalData[$baseName].sub = $data
    }
}

# ==== Output per object ====
$totalFrames = 0
$totalSeconds = 0.0

function Get-ColorForExp($exp) {
    switch ($exp) {
        10 { return 'Green' }       # 🟩
        20 { return 'Yellow' }      # 🟨
        30 { return 'DarkYellow' }  # 🟧
        default { return 'Cyan' }   # 🩵 (60s+)
    }
}

function Format-FolderOutput {
    param ($label, $info)
    $sec = $info.Seconds
    $hrs = $sec / 3600
    $summaryParts = @()

    foreach ($kv in ($info.Exposures.GetEnumerator() | Sort-Object Name)) {
        $exp = $kv.Key
        $count = $kv.Value
        $share = if ($sec -gt 0) { [math]::Round(($exp * $count / $sec) * 100) } else { 0 }
        $color = Get-ColorForExp $exp
        $part = ("{0}x{1}s {2}%" -f $count, $exp, $share)
        $summaryParts += @{ text = $part; color = $color }
    }

    $failStr = ""
    if ($info.Failed -gt 0) {
        Write-Host ("{0,-25} | {1,4} frames | {2,8:N0}s {3,6:N2}h | " -f $label, $info.Frames, $sec, $hrs) -NoNewline

        $first = $true
        foreach ($item in $summaryParts) {
            if (-not $first) { Write-Host ", " -NoNewline }
            Write-Host $item.text -ForegroundColor $item.color -NoNewline
            $first = $false
        }

        Write-Host " Failed:" -NoNewline
        Write-Host (" {0}" -f $info.Failed) -ForegroundColor Red
    } else {
        Write-Host ("{0,-25} | {1,4} frames | {2,8:N0}s {3,6:N2}h | " -f $label, $info.Frames, $sec, $hrs) -NoNewline

        $first = $true
        foreach ($item in $summaryParts) {
            if (-not $first) { Write-Host ", " -NoNewline }
            Write-Host $item.text -ForegroundColor $item.color -NoNewline
            $first = $false
        }
        Write-Host ""
    }
}

foreach ($key in ($globalData.Keys | Sort-Object)) {
    $obj = $globalData[$key]
    $hasSub = $obj.sub -ne $null -and $obj.sub.Frames -gt 0
    $hasMosaic = $obj.mosaic -ne $null -and $obj.mosaic.Frames -gt 0

    if (-not ($hasSub -or $hasMosaic)) { continue }

    if ($hasSub -and -not $hasMosaic) {
        Format-FolderOutput $key $obj.sub
        $totalFrames += $obj.sub.Frames
        $totalSeconds += $obj.sub.Seconds
        continue
    }

    if ($hasSub) {
        Format-FolderOutput ("{0}_sub" -f $key) $obj.sub
        $totalFrames += $obj.sub.Frames
        $totalSeconds += $obj.sub.Seconds
    }
    if ($hasMosaic) {
        Format-FolderOutput ("{0}_mosaic_sub" -f $key) $obj.mosaic
        $totalFrames += $obj.mosaic.Frames
        $totalSeconds += $obj.mosaic.Seconds
    }

    if ($hasSub -and $hasMosaic) {
        $combined = @{
            Frames = $obj.sub.Frames + $obj.mosaic.Frames
            Seconds = $obj.sub.Seconds + $obj.mosaic.Seconds
            Failed = $obj.sub.Failed + $obj.mosaic.Failed
            Exposures = @{}
        }

        foreach ($kv in $obj.sub.Exposures.GetEnumerator()) {
            $exp = $kv.Key
            $count = $kv.Value
            $combined.Exposures[$exp] = $count
        }
        foreach ($kv in $obj.mosaic.Exposures.GetEnumerator()) {
            $exp = $kv.Key
            $count = $kv.Value
            if ($combined.Exposures.ContainsKey($exp)) {
                $combined.Exposures[$exp] += $count
            } else {
                $combined.Exposures[$exp] = $count
            }
        }

        Format-FolderOutput ("{0}_sub + {0}_mosaic_sub" -f $key) $combined
    }
}

# ==== Global summary ====
Write-Host "`n--------------------------------------------"
Write-Host "Global Summary:" -ForegroundColor Green
Write-Host (" Total frames: {0}" -f $totalFrames)
Write-Host (" Total failed frames: {0}" -f $totalFailed)
Write-Host (" Total exposure: {0}s | {1}min | {2:N2}h" -f ([int]$totalSeconds), ([int]($totalSeconds/60)), ($totalSeconds/3600))
Write-Host "--------------------------------------------`n"
Write-Host "Press Enter to close..."
Read-Host
