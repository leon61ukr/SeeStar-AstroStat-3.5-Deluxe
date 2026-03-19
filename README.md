# 🌌 SeeStar AstroStat 4.0 Deluxe

**SeeStar AstroStat** is a smart and colorful PowerShell utility that analyzes astrophotography session data from **SeeStar S30/S50** or any FIT/FITS-based imaging workflow.  
It automatically scans your session folders, sums up all exposure data, and gives you a clean, human-readable summary — including per-target and global stats.

---

## ✨ Features

- 🔭 Automatically detects and groups `_sub` and `_mosaic_sub` folders  
- 🧮 Calculates total frames, exposure time (in seconds, minutes, hours)  
- 💥 Handles both stacked and light FIT files  
- 📊 Provides detailed exposure breakdowns (10s, 20s, 30s, 60s+)  
- 🎨 Color-coded output:
  - 🟩 **10s** exposures  
  - 🟨 **20s** exposures  
  - 🟧 **30s** exposures  
  - 🩵 **60s+** exposures  
  - ❤️ Failed frames count
- 🧩 Combines stats for `_sub` + `_mosaic_sub` sessions of the same target  
- 🪶 Lightweight and standalone — no dependencies or installation needed
- 📊 Automatically sorts objects by total exposure time (longest first)  
- 📝 Saves session summaries to `_logs` folder  
- 🧠 Detects unchanged runs and avoids duplicate logs  
- 🔄 Tracks changes between runs (added/removed exposure time per object)  
- 📈 Displays exposure differences in hours between sessions  
- ⚡ Includes lightweight loading animation during processing  
---

## 🆕 What’s New in 4.0
- ⚡ Loading animation (spinner)
  - Added an animated Calculating... indicator while processing folders
- 📊 Sorting by total exposure time
  - Objects are now automatically sorted by total exposure time (descending)
  - → longest / most significant sessions appear first
- 📝 Full session logging
  - The script now saves results to a _logs folder:
  - automatic folder creation
  - timestamped log files (yyyy-MM-dd-HHmm.txt)
  - UTF-8 encoding without BOM
- 🧠 Smart log deduplication (SHA-256)
  - A new log is NOT created if:
  - no data has changed
  - comparison is done using hash
- 🔄 Change tracking between runs
  - Displays differences between current and previous runs:
  - ➕ added exposure time per object
  - ➖ removed objects
  - 🔼 / 🔽 exposure changes
- 📈 Per-object exposure delta (in hours)
  - Calculates exposure change in hours for each object:
  - M31 : +1.25 h
  - M42 : -0.40 h
  - REMOVED: M51
- 🎯 Improved output consistency
  - unified logic for console and log output
  - synchronized line formatting
- 🧹 Cleaner output logic
  - reduced code duplication
  - unified handling of failed frames
  - more stable output format
- 🔧 Refactored data merging
  - Improved merging logic for _sub + _mosaic_sub:
  - cleaner exposure merging
  - fewer edge-case issues

## 🚀 How to Use

1. Download or copy the script file —  
   `SeeStar_AstroStat_4.0_Deluxe.ps1`
2. Place it inside your **MyWork** folder (or wherever you store all your star captures).
3. Right-click the file → **“Run with PowerShell.”**

---

## 🖥️ Example Output
```
=== SeeStar AstroStat 4.0 Deluxe ===
M 31_sub                  |   90 frames |      930s   0,26h | 87x10s 94%, 3x20s 6%
M 31_mosaic_sub           | 5306 frames |   57 340s  15,93h | 4906x10s 86%, 372x20s 13%, 28x30s 1%
M 31_sub + M 31_mosaic_sub | 5396 frames |   58 270s  16,19h | 4993x10s 86%, 375x20s 13%, 28x30s 1%
M 97                      | 1507 frames |   18 270s   5,08h | 1187x10s 65%, 320x20s 35%
NGC 2903                  |  762 frames |    9 720s   2,70h | 552x10s 57%, 210x20s 43% Failed: 5
IC 2574                   |  709 frames |    8 900s   2,47h | 528x10s 59%, 181x20s 41%
M 109                     |  674 frames |    8 540s   2,37h | 494x10s 58%, 180x20s 42%
NGC 6888                  |  662 frames |    8 420s   2,34h | 482x10s 57%, 180x20s 43% Failed: 40
SH 2- 142                 |  760 frames |    8 080s   2,24h | 712x10s 88%, 48x20s 12% Failed: 3
M 101                     |  582 frames |    7 940s   2,21h | 370x10s 47%, 212x20s 53% Failed: 6
NGC 2403                  |  502 frames |    7 580s   2,11h | 246x10s 32%, 256x20s 68%
Markarian's Chain_mosaic_sub |  740 frames |    7 400s   2,06h | 740x10s 100%
NGC 6946                  |  410 frames |    7 260s   2,02h | 161x10s 22%, 197x20s 54%, 47x30s 19%, 5x60s 4% Failed: 17
--------------------------------------------
Global Summary:
 Total frames: 18709
 Total failed frames: 1228
 Total exposure: 221580s | 3693min | 61,55h
--------------------------------------------

Changes from last script execution:
 IC 2574 : +1.45 h
 IC 417 : +0.57 h
 IC 447 : +0.06 h
 M 101 : +1.18 h
 M 102 : +0.2 h
 M 106 : +0.05 h
 M 109 : +1 h
 M 63 : +0.66 h
 M 78 : +1.26 h
 NGC 2403 : +2.11 h
 NGC 4236 : +1.02 h
 NGC 5907 : +0.24 h
```

---

## 🧰 Requirements

- Windows 10/11  
- PowerShell 5.1 or newer  
- FIT or FITS files named with exposure time (e.g., `Light_10s.fit`, `Stacked_30_10s.fit`, etc.)

---

## 🪐 Author

**Developed by:** LeoN61ukr
**Version:** 4.0 Deluxe  
**License:** MIT  

> Made for all SeeStar explorers who love both stars and stats 🌟

---
