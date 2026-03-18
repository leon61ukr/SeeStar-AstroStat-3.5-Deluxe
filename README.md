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
C2025 A6 (Lemmon)         |  846 frames |    8 940s   2,48h | 798x10s 89%, 48x20s 11% 
IC 1848                   |   41 frames |      410s   0,11h | 41x10s 100% Failed: 6
IC 5146                   |  110 frames |    2 640s   0,73h | 27x10s 10%, 27x20s 20%, 51x30s 58%, 5x60s 11% Failed: 23
M 31_sub                  |   90 frames |      930s   0,26h | 87x10s 94%, 3x20s 6%
M 31_mosaic_sub           | 5306 frames |   57 340s  15,93h | 4906x10s 86%, 372x20s 13%, 28x30s 1%
M 31_sub + M 31_mosaic_sub | 5396 frames |   58 270s  16,19h | 4993x10s 86%, 375x20s 13%, 28x30s 1% 
M 33_sub                  |  311 frames |    3 510s   0,98h | 291x10s 83%, 20x30s 17% Failed: 23
M 33_mosaic_sub           |  335 frames |    3 350s   0,93h | 335x10s 100%
M 33_sub + M 33_mosaic_sub |  646 frames |    6 860s   1,91h | 626x10s 91%, 20x30s 9% Failed: 23
NGC 6946                  |  289 frames |    4 840s   1,34h | 161x10s 33%, 76x20s 31%, 47x30s 29%, 5x60s 6% Failed: 17
Vega                      |    3 frames |       30s   0,01h | 3x10s 100%
--------------------------------------------
Global Summary:
 Total frames: 18709
 Total failed frames: 1228
 Total exposure: 221580s | 3693min | 61,55h
--------------------------------------------

Changes from last script execution:
 IC 1805 : -0.01 h
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
