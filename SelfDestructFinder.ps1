param([switch]$NoPause)

$ErrorActionPreference = 'SilentlyContinue'
$script:Findings = New-Object System.Collections.Generic.List[object]
$script:Now = Get-Date

function Write-Header {
    Clear-Host
    Write-Host "╔════════════════════════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║" -ForegroundColor Green -NoNewline
    Write-Host "          MINECRAFT SELF DESTRUCT FINDER          " -ForegroundColor White -NoNewline
    Write-Host "║" -ForegroundColor Green
    Write-Host "╚════════════════════════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host

    Write-Host "  ███╗   ███╗██╗███╗   ██╗███████╗ ██████╗██████╗  █████╗ ███████╗████████╗" -ForegroundColor Green
    Write-Host "  ████╗ ████║██║████╗  ██║██╔════╝██╔════╝██╔══██╗██╔══██╗██╔════╝╚══██╔══╝" -ForegroundColor Green
    Write-Host "  ██╔████╔██║██║██╔██╗ ██║█████╗  ██║     ██████╔╝███████║█████╗     ██║   " -ForegroundColor Green
    Write-Host "  ██║╚██╔╝██║██║██║╚██╗██║██╔══╝  ██║     ██╔══██╗██╔══██║██╔══╝     ██║   " -ForegroundColor Green
    Write-Host "  ██║ ╚═╝ ██║██║██║ ╚████║███████╗╚██████╗██║  ██║██║  ██║██║        ██║   " -ForegroundColor Green
    Write-Host "  ╚═╝     ╚═╝╚═╝╚═╝  ╚═══╝╚══════╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝        ╚═╝   " -ForegroundColor Green
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

function Search-SelfDestruct {
    $mcPath = Join-Path $env:USERPROFILE "AppData\Roaming\.minecraft"

    Write-Host "[i] Diepe scan op self-destruct sporen..." -ForegroundColor Cyan

    # 1. Minecraft logs + configs op inhoud
    if (Test-Path $mcPath) {
        Get-ChildItem -Path $mcPath -Recurse -File -ErrorAction SilentlyContinue -Depth 6 | Where-Object { $_.Extension -in '.log','.txt','.json','.cfg' } | ForEach-Object {
            $content = Get-Content $_.FullName -Raw -ErrorAction SilentlyContinue
            if ($content -match '(?i)self.?destruct|autodestruct|destruct|injector|doomsday|ceymer|prestige|tempcheat') {
                Add-Finding -Severity 'HIGH' -Category 'Self Destruct Log/Content Trace' -Evidence $_.Name -Path $_.FullName -Details "Inhoud bevat self-destruct aanwijzingen"
            }
        }
    }

    # 2. Temp bestanden (zeer belangrijk voor self-destruct)
    Write-Host "[i] Scanning Temp bestanden..." -ForegroundColor Cyan
    Get-ChildItem -Path $env:TEMP, "$env:LOCALAPPDATA\Temp" -Recurse -File -ErrorAction SilentlyContinue -Depth 5 | ForEach-Object {
        if ($_.Name -match '(?i)selfdestruct|autodestruct|destruct|injector|tempcheat') {
            Add-Finding -Severity 'HIGH' -Category 'Self Destruct Temp File' -Evidence $_.Name -Path $_.FullName
        }
    }

    # 3. Prefetch + Registry hints
    Write-Host "[i] Scanning Prefetch..." -ForegroundColor Cyan
    $prefetch = Join-Path $env:SystemRoot "Prefetch"
    if (Test-Path $prefetch) {
        Get-ChildItem -Path $prefetch -File | Where-Object { $_.Name -match '(?i)DOOMSDAY|CEYMER|PRESTIGE|INJECTOR' } | ForEach-Object {
            Add-Finding -Severity 'HIGH' -Category 'Prefetch Execution Trace' -Evidence $_.Name -Path $_.FullName
        }
    }

    # 4. Extra brede scan op verdachte patronen
    Get-ChildItem -Path $env:USERPROFILE -Recurse -File -ErrorAction SilentlyContinue -Depth 4 -Include "*.jar","*.dll","*.exe" | Select-Object -First 300 | ForEach-Object {
        if ($_.Name -match '(?i)injector|loader|selfdestruct') {
            Add-Finding -Severity 'MEDIUM' -Category 'Suspicious Executable' -Evidence $_.Name -Path $_.FullName
        }
    }
}

Write-Header
Search-SelfDestruct

Write-Host "`n" + ("═" * 100) -ForegroundColor Green

$high = @($script:Findings | Where-Object Severity -eq 'HIGH').Count
$medium = @($script:Findings | Where-Object Severity -eq 'MEDIUM').Count

Write-Host " HIGH   : $high" -ForegroundColor Red
Write-Host " MEDIUM : $medium" -ForegroundColor Yellow
Write-Host

if ($script:Findings.Count -eq 0) {
    Write-Host " [OK] Geen duidelijke self-destruct sporen gevonden." -ForegroundColor Green
} else {
    $script:Findings | Sort-Object Severity -Descending | ForEach-Object {
        $col = if ($_.Severity -eq 'HIGH') { 'Red' } else { 'Yellow' }
        Write-Host "[$($_.Severity)] $($_.Category)" -ForegroundColor $col
        Write-Host "   Evidence : $($_.Evidence)" 
        Write-Host "   Path     : $($_.Path)"
        if ($_.Details) { Write-Host "   Details  : $($_.Details)" }
        Write-Host
    }
}

Write-Host ("═" * 100) -ForegroundColor Green
if (-not $NoPause) { Read-Host 'Druk op Enter om af te sluiten' }
