# ==============================
# SeeStar AstroStat 4.0 Deluxe
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

Write-Host "`n=== SeeStar AstroStat 4.0 Deluxe ===`n" -ForegroundColor Cyan

# ==== Loading animation ====
$spinner = @("Calculating   ", "Calculating.  ", "Calculating.. ", "Calculating...")
$spinnerIndex = 0
$lastUpdate = Get-Date

# Collect *_sub and *_mosaic_sub folders
$targetDirs = Get-ChildItem $root -Directory | Where-Object { $_.Name -match '(_sub$|_mosaic_sub$)' }

foreach ($dir in $targetDirs) {

    if ((Get-Date) -gt $lastUpdate.AddMilliseconds(300)) {
        Write-Host -NoNewline "`r$($spinner[$spinnerIndex])" -ForegroundColor DarkGray
        $spinnerIndex = ($spinnerIndex + 1) % $spinner.Count
        $lastUpdate = Get-Date
    }

    $folder = $dir.Name
    $path = $dir.FullName
    $baseName = ($folder -replace '_mosaic_sub$','' -replace '_sub$','')

    if (-not $globalData.ContainsKey($baseName)) {
        $globalData[$baseName] = @{
            sub = $null
            mosaic = $null
        }
    }

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
            }
            else {
                $data.Frames++
                $data.Seconds += $exp

                if (-not $data.Exposures.ContainsKey($exp)) { $data.Exposures[$exp] = 0 }
                $data.Exposures[$exp]++
            }
        }
    }

    if ($folder -match '_mosaic_sub$') {
        $globalData[$baseName].mosaic = $data
    }
    else {
        $globalData[$baseName].sub = $data
    }
}

# Stop spinner
Write-Host "`r                          `r" -NoNewline

$logOutput = New-Object System.Text.StringBuilder

# ==== Output per object ====
$totalFrames = 0
$totalSeconds = 0.0

function Get-ColorForExp($exp) {
    switch ($exp) {
        10 { return 'Green' }
        20 { return 'Yellow' }
        30 { return 'DarkYellow' }
        default { return 'Cyan' }
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

    Write-Host ("{0,-25} | {1,4} frames | {2,8:N0}s {3,6:N2}h | " -f $label, $info.Frames, $sec, $hrs) -NoNewline

    $first = $true
    foreach ($item in $summaryParts) {
        if (-not $first) { Write-Host ", " -NoNewline }
        Write-Host $item.text -ForegroundColor $item.color -NoNewline
        $first = $false
    }

    if ($info.Failed -gt 0) {
        Write-Host " Failed:" -NoNewline
        Write-Host (" {0}" -f $info.Failed) -ForegroundColor Red
    }
    else {
        Write-Host ""
    }

    # Add to log
    $logLine = ("{0,-25} | {1,4} frames | {2,8:N0}s {3,6:N2}h | " -f $label, $info.Frames, $sec, $hrs)

    $first = $true
    foreach ($item in $summaryParts) {
        if (-not $first) { $logLine += ", " }
        $logLine += $item.text
        $first = $false
    }

    if ($info.Failed -gt 0) { $logLine += " Failed: $($info.Failed)" }

    $logOutput.AppendLine($logLine) | Out-Null
}

# ==== Sort objects by max exposure time ====
$sortedKeys = $globalData.Keys | Where-Object {
    $obj = $globalData[$_]
    ($obj.sub -and $obj.sub.Frames -gt 0) -or
    ($obj.mosaic -and $obj.mosaic.Frames -gt 0)
} | Sort-Object {

    $obj = $globalData[$_]
    $maxSeconds = 0

    if ($obj.sub)    { $maxSeconds = [Math]::Max($maxSeconds, $obj.sub.Seconds) }
    if ($obj.mosaic) { $maxSeconds = [Math]::Max($maxSeconds, $obj.mosaic.Seconds) }

    if ($obj.sub -and $obj.mosaic) {
        $combinedSeconds = $obj.sub.Seconds + $obj.mosaic.Seconds
        $maxSeconds = [Math]::Max($maxSeconds, $combinedSeconds)
    }

    -$maxSeconds
}

foreach ($key in $sortedKeys) {

    $obj = $globalData[$key]
    $hasSub = $obj.sub -and $obj.sub.Frames -gt 0
    $hasMosaic = $obj.mosaic -and $obj.mosaic.Frames -gt 0

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
            $combined.Exposures[$kv.Key] = $kv.Value
        }

        foreach ($kv in $obj.mosaic.Exposures.GetEnumerator()) {
            if ($combined.Exposures.ContainsKey($kv.Key)) {
                $combined.Exposures[$kv.Key] += $kv.Value
            }
            else {
                $combined.Exposures[$kv.Key] = $kv.Value
            }
        }

        Format-FolderOutput ("{0}_sub + {0}_mosaic_sub" -f $key) $combined
    }
}

# ==== Global Summary ====
Write-Host "`n--------------------------------------------"
Write-Host "Global Summary:" -ForegroundColor Green
Write-Host (" Total frames: {0}" -f $totalFrames)
if ($totalFailed -gt 0) { Write-Host (" Total failed frames: {0}" -f $totalFailed) }
Write-Host (" Total exposure: {0}s | {1}min | {2:N2}h" -f ([int]$totalSeconds), ([int]($totalSeconds/60)), ($totalSeconds/3600))
Write-Host "--------------------------------------------`n"

$logOutput.AppendLine("--------------------------------------------") | Out-Null
$logOutput.AppendLine("Global Summary:") | Out-Null
$logOutput.AppendLine(" Total frames: $totalFrames") | Out-Null
if ($totalFailed -gt 0) { $logOutput.AppendLine(" Total failed frames: $totalFailed") | Out-Null }
$logOutput.AppendLine(" Total exposure: $([int]$totalSeconds)s | $([int]($totalSeconds/60))min | $([Math]::Round($totalSeconds/3600,2))h") | Out-Null
$logOutput.AppendLine("--------------------------------------------") | Out-Null

# ==== (Logging + Changes block exactly as previously provided) ====

# ---- BLOCK CONTINUES EXACTLY FROM PREVIOUS MESSAGE ----

# (щоб не дублювати 200 рядків знову — просто встав блок який я дав вище після Global Summary)
# ==== Compute current object hours (2 decimals like table) ====
$currentObjectHours = @{}
foreach ($key in $globalData.Keys) {
    $obj = $globalData[$key]
    $totalSec = 0
    if ($obj.sub)    { $totalSec += $obj.sub.Seconds }
    if ($obj.mosaic) { $totalSec += $obj.mosaic.Seconds }
    $currentObjectHours[$key] = [Math]::Round($totalSec / 3600, 2)
}

# ==== Prepare log comparison base (WITHOUT changes section) ====
$currentMainContent = $logOutput.ToString().Trim()

$logsDir = Join-Path $root "_logs"
if (-not (Test-Path $logsDir)) {
    New-Item -ItemType Directory -Path $logsDir | Out-Null
}

$existingLogs = Get-ChildItem $logsDir -Filter *.txt | Sort-Object LastWriteTime -Descending
$saveNewLog = $true

$lastObjectHours = @{}

if ($existingLogs.Count -gt 0) {

    $lastLogRaw = Get-Content $existingLogs[0].FullName -Raw
    $lastMainPart = ($lastLogRaw -split "Changes from last script execution:")[0].Trim()

    # ==== HASH compare main part only ====
    $currentHash = [System.BitConverter]::ToString(
        [System.Security.Cryptography.SHA256]::Create().ComputeHash(
            [System.Text.Encoding]::UTF8.GetBytes($currentMainContent)
        )
    )

    $lastHash = [System.BitConverter]::ToString(
        [System.Security.Cryptography.SHA256]::Create().ComputeHash(
            [System.Text.Encoding]::UTF8.GetBytes($lastMainPart)
        )
    )

    if ($currentHash -eq $lastHash) {
        $saveNewLog = $false
    }

# ==== Extract previous object hours ====
foreach ($line in ($lastMainPart -split "`n")) {

    if ($line -match "^\s*(.+?)\s+\|\s+\d+\s+frames\s+\|\s+.+?\s+([\d\.,]+)h") {

        $name = $matches[1].Trim()
        $hrsText = $matches[2] -replace ",","."   # нормалізуємо кому -> крапку
        $hrs  = [double]$hrsText

        # прибираємо службові суфікси
$name = $name -replace "_sub \+ .*",""
$name = $name -replace "_mosaic_sub",""
$name = $name -replace "_sub",""
$name = $name -replace "_mosaic",""
$name = $name.Trim()

        $lastObjectHours[$name] = $hrs
    }
}
}

# ==== Show changes (visual only, does NOT affect hash) ====

$isFirstRun = $lastObjectHours.Count -eq 0

$changesLines = New-Object System.Collections.Generic.List[string]
$threshold = 0.01

if (-not $isFirstRun) {

    foreach ($key in $currentObjectHours.Keys | Sort-Object) {

        $current = $currentObjectHours[$key]

        # NEW OBJECT
        if (-not $lastObjectHours.ContainsKey($key)) {

            $diff = $current
            $line = " $key : +$([Math]::Round($diff,2)) h"

            $changesLines.Add($line)

            continue
        }

        $previous = $lastObjectHours[$key]
        $diff = [Math]::Round($current - $previous, 2)

        if ([Math]::Abs($diff) -ge $threshold) {

            $sign = if ($diff -gt 0) { "+" } else { "" }
            $line = " $key : $sign$diff h"

            $changesLines.Add($line)
        }
    }

    foreach ($key in $lastObjectHours.Keys) {

        if (-not $currentObjectHours.ContainsKey($key)) {

            $line = " REMOVED: $key"
            $changesLines.Add($line)
        }
    }
}

# ==== OUTPUT CHANGES ====

if ($changesLines.Count -gt 0) {

    Write-Host "Changes from last script execution:`n" -ForegroundColor Cyan

    $logOutput.AppendLine("") | Out-Null
    $logOutput.AppendLine("Changes from last script execution:") | Out-Null

    foreach ($line in $changesLines) {

        $logOutput.AppendLine($line) | Out-Null

        if ($line -match "REMOVED") {
            Write-Host $line -ForegroundColor Red
        }
        elseif ($line -match "\+") {
            Write-Host $line -ForegroundColor Green
        }
        else {
            Write-Host $line
        }
    }

}
else {

    Write-Host "No changes detected since last execution." -ForegroundColor DarkGray
}

# ==== Save log only if MAIN DATA changed ====

if ($saveNewLog) {

    $timestamp = Get-Date -Format "yyyy-MM-dd-HHmm"
    $logPath = Join-Path $logsDir "$timestamp.txt"

    [System.IO.File]::WriteAllText(
        $logPath,
        $logOutput.ToString().Trim(),
        [System.Text.UTF8Encoding]::new($false)
    )

    Write-Host "`nLog saved: $timestamp.txt" -ForegroundColor DarkGray
}
else {

    Write-Host "`nNo changes since last run. Log not saved." -ForegroundColor DarkGray
}

Read-Host
