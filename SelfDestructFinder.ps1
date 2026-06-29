param([switch]$NoPause)

$ErrorActionPreference = 'SilentlyContinue'
$script:Findings = New-Object System.Collections.Generic.List[object]
$script:Now = Get-Date
$script:LogFile = "$env:USERPROFILE\Desktop\SelfDestruct_Scan_Result.txt"

function Write-Header {
    Clear-Host
    Write-Host "╔════════════════════════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║" -ForegroundColor Green -NoNewline
    Write-Host "          MINECRAFT SELF DESTRUCT FINDER          " -ForegroundColor White -NoNewline
    Write-Host "║" -ForegroundColor Green
    Write-Host "╚════════════════════════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host

    Write-Host "                        SELF" -ForegroundColor Green
    Write-Host "                      DESTRUCT" -ForegroundColor Green
    Write-Host "                      DETECTOR" -ForegroundColor Green
    Write-Host
    Write-Host ("═" * 100) -ForegroundColor Green
    Write-Host (" Scan started: {0}" -f $script:Now.ToString('yyyy-MM-dd HH:mm:ss')) -ForegroundColor White
    Write-Host ("═" * 100) -ForegroundColor Green
    Write-Host
}

function Write-ProgressBar {
    param([int]$Percent, [string]$Status)
    $width = 60
    $filled = [math]::Floor(($Percent / 100) * $width)
    $empty = $width - $filled
    $bar = ('█' * $filled) + ('░' * $empty)
    Write-Host ("`r[ {0} ] {1,3}% {2}" -f $bar, $Percent, $Status) -ForegroundColor Green -NoNewline
    if ($Percent -ge 100) { Write-Host }
}

function Add-Finding {
    param([string]$Severity, [string]$Category, [string]$Evidence, [string]$Path, [string]$Details = "")
    $script:Findings.Add([pscustomobject]@{
        Severity = $Severity
        Category = $Category
        Evidence = $Evidence
        Path = $Path
        Details = $Details
    })
}

function Is-OwnTool {
    param([string]$Path)
    if ([string]::IsNullOrEmpty($Path)) { return $false }
    $lower = $Path.ToLower()
    $badWords = @("finder","detector","scanner","fucker","injectorscanner","selfdestructfinder","selfdestruct","ps1")
    foreach ($word in $badWords) {
        if ($lower.Contains($word)) { return $true }
    }
    return $false
}

function Search-SelfDestruct {
    Write-ProgressBar -Percent 10 -Status "Scanning Minecraft folder..."
    $mcPath = Join-Path $env:USERPROFILE "AppData\Roaming\.minecraft"

    if (Test-Path $mcPath) {
        Get-ChildItem -Path $mcPath -Recurse -File -ErrorAction SilentlyContinue -Depth 6 | ForEach-Object {
            if (Is-OwnTool $_.FullName) { return }
            $content = ""
            if ($_.Extension -in '.log','.txt') {
                $content = Get-Content $_.FullName -Raw -ErrorAction SilentlyContinue
            }
            if ($content -match '(?i)self.?destruct|autodestruct|destruct.*inject|inject.*destruct|doomsday|ceymer|prestige.*destruct') {
                Add-Finding -Severity 'HIGH' -Category 'Self Destruct Content Trace' -Evidence $_.Name -Path $_.FullName
            }
        }
    }

    Write-ProgressBar -Percent 50 -Status "Scanning Temp files..."
    Get-ChildItem -Path $env:TEMP, "$env:LOCALAPPDATA\Temp" -Recurse -File -ErrorAction SilentlyContinue -Depth 5 | ForEach-Object {
        if (Is-OwnTool $_.FullName) { return }
        if ($_.Name -match '(?i)selfdestruct|autodestruct|destruct.*inject|injector.*temp') {
            Add-Finding -Severity 'HIGH' -Category 'Self Destruct Temp File' -Evidence $_.Name -Path $_.FullName
        }
    }

    Write-ProgressBar -Percent 80 -Status "Scanning Prefetch..."
    $prefetch = Join-Path $env:SystemRoot "Prefetch"
    if (Test-Path $prefetch) {
        Get-ChildItem -Path $prefetch -File | Where-Object { $_.Name -match '(?i)DOOMSDAY|CEYMER|PRESTIGE.*INJECT' } | ForEach-Object {
            Add-Finding -Severity 'HIGH' -Category 'Prefetch Trace' -Evidence $_.Name -Path $_.FullName
        }
    }

    Write-ProgressBar -Percent 100 -Status "Scan complete"
}

Write-Header
Search-SelfDestruct

"Self Destruct Scan Result - $($script:Now)" | Out-File $script:LogFile
"================================================================" | Out-File $script:LogFile -Append

Write-Host "`n" + ("═" * 100) -ForegroundColor Green

if ($script:Findings.Count -eq 0) {
    Write-Host " [OK] Geen duidelijke self-destruct sporen gevonden." -ForegroundColor Green
    "Geen sporen gevonden." | Out-File $script:LogFile -Append
} else {
    $high = @($script:Findings | Where-Object Severity -eq 'HIGH').Count
    Write-Host " HIGH : $high" -ForegroundColor Red
    "HIGH : $high" | Out-File $script:LogFile -Append

    $script:Findings | Sort-Object Severity -Descending | ForEach-Object {
        $col = if ($_.Severity -eq 'HIGH') { 'Red' } else { 'Yellow' }
        Write-Host "[$($_.Severity)] $($_.Category)" -ForegroundColor $col
        Write-Host "   Evidence : $($_.Evidence)" 
        Write-Host "   Path     : $($_.Path)"
        Write-Host
        "[$($_.Severity)] $($_.Category) | Path: $($_.Path)" | Out-File $script:LogFile -Append
    }
}

Write-Host ("═" * 100) -ForegroundColor Green
Write-Host "Resultaten opgeslagen in: $script:LogFile" -ForegroundColor Green
if (-not $NoPause) { Read-Host 'Druk op Enter om af te sluiten' }
