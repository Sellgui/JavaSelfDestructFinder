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

    # Minecraft banner (referentie grootte)
    Write-Host "  ███╗   ███╗██╗███╗   ██╗███████╗ ██████╗██████╗  █████╗ ███████╗████████╗" -ForegroundColor Green
    Write-Host "  ████╗ ████║██║████╗  ██║██╔════╝██╔════╝██╔══██╗██╔══██╗██╔════╝╚══██╔══╝" -ForegroundColor Green
    Write-Host "  ██╔████╔██║██║██╔██╗ ██║█████╗  ██║     ██████╔╝███████║█████╗     ██║   " -ForegroundColor Green
    Write-Host "  ██║╚██╔╝██║██║██║╚██╗██║██╔══╝  ██║     ██╔══██╗██╔══██║██╔══╝     ██║   " -ForegroundColor Green
    Write-Host "  ██║ ╚═╝ ██║██║██║ ╚████║███████╗╚██████╗██║  ██║██║  ██║██║        ██║   " -ForegroundColor Green
    Write-Host "  ╚═╝     ╚═╝╚═╝╚═╝  ╚═══╝╚══════╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝        ╚═╝   " -ForegroundColor Green
    Write-Host

    # SELF, DESTRUCT, DETECTOR - iets kleiner maar nog steeds bold
    Write-Host "   ███████╗███████╗██╗     ███████╗" -ForegroundColor Green
    Write-Host "   ██╔════╝██╔════╝██║     ██╔════╝" -ForegroundColor Green
    Write-Host "   ███████╗█████╗  ██║     █████╗  " -ForegroundColor Green
    Write-Host "   ╚════██║██╔══╝  ██║     ██╔══╝  " -ForegroundColor Green
    Write-Host "   ███████║███████╗███████╗██║     " -ForegroundColor Green
    Write-Host "   ╚══════╝╚══════╝╚══════╝╚═╝      " -ForegroundColor Green
    Write-Host

    Write-Host "  ██████╗ ███████╗███████╗████████╗██████╗ ██╗   ██╗ ██████╗████████╗" -ForegroundColor Green
    Write-Host "  ██╔══██╗██╔════╝██╔════╝╚══██╔══╝██╔══██╗██║   ██║██╔════╝╚══██╔══╝" -ForegroundColor Green
    Write-Host "  ██║  ██║█████╗  ███████╗   ██║   ██████╔╝██║   ██║██║        ██║   " -ForegroundColor Green
    Write-Host "  ██║  ██║██╔══╝  ╚════██║   ██║   ██╔══██╗██║   ██║██║        ██║   " -ForegroundColor Green
    Write-Host "  ██████╔╝███████╗███████║   ██║   ██║  ██║╚██████╔╝╚██████╗   ██║   " -ForegroundColor Green
    Write-Host "  ╚═════╝ ╚══════╝╚══════╝   ╚═╝   ╚═╝  ╚═╝ ╚═════╝  ╚═════╝   ╚═╝   " -ForegroundColor Green
    Write-Host

    Write-Host "  ██████╗ ███████╗████████╗███████╗ ██████╗████████╗ ██████╗ ██████╗ " -ForegroundColor Green
    Write-Host "  ██╔══██╗██╔════╝╚══██╔══╝██╔════╝██╔════╝╚══██╔══╝██╔═══██╗██╔══██╗" -ForegroundColor Green
    Write-Host "  ██║  ██║█████╗     ██║   █████╗  ██║        ██║   ██║   ██║██████╔╝" -ForegroundColor Green
    Write-Host "  ██║  ██║██╔══╝     ██║   ██╔══╝  ██║        ██║   ██║   ██║██╔══██╗" -ForegroundColor Green
    Write-Host "  ██████╔╝███████╗   ██║   ███████╗╚██████╗   ██║   ╚██████╔╝██║  ██║" -ForegroundColor Green
    Write-Host "  ╚═════╝ ╚══════╝   ╚═╝   ╚══════╝ ╚═════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝" -ForegroundColor Green

    Write-Host
    Write-Host ("═" * 100) -ForegroundColor Green
    Write-Host (" Scan started: {0}" -f $script:Now.ToString('yyyy-MM-dd HH:mm:ss')) -ForegroundColor White
    Write-Host ("═" * 100) -ForegroundColor Green
    Write-Host
}

function Add-Finding {
    param([string]$Severity, [string]$Category, [string]$Evidence, [string]$Path)
    $script:Findings.Add([pscustomobject]@{
        Severity = $Severity
        Category = $Category
        Evidence = $Evidence
        Path = $Path
    })
}

function Search-SelfDestruct {
    $minecraftPath = Join-Path $env:USERPROFILE "AppData\Roaming\.minecraft"
    $specialClients = @('doomsday','ceymer','prestige','meteor','wurst','rise','future','aristois')

    Write-Host "[i] Scanning .minecraft folder..." -ForegroundColor Cyan

    if (Test-Path $minecraftPath) {
        Get-ChildItem -Path $minecraftPath -Recurse -File -ErrorAction SilentlyContinue -Depth 6 |
            Where-Object { $_.Extension -in '.jar','.log','.json','.cfg','.txt' } | ForEach-Object {
                $name = $_.Name.ToLower()
                foreach ($client in $specialClients) {
                    if ($name.Contains($client)) {
                        $sev = if ($client -in @('doomsday','ceymer','prestige','meteor','rise')) { 'HIGH' } else { 'MEDIUM' }
                        Add-Finding -Severity $sev -Category 'Special Client Remnant' -Evidence $_.Name -Path $_.FullName
                    }
                }
                if ($name -match 'self.?destruct|autodestruct|destruct|injector') {
                    Add-Finding -Severity 'HIGH' -Category 'Self Destruct Remnant' -Evidence $_.Name -Path $_.FullName
                }
            }
    }

    Write-Host "[i] Scanning Temp folders..." -ForegroundColor Cyan
    Get-ChildItem -Path $env:TEMP, "$env:LOCALAPPDATA\Temp" -Recurse -File -ErrorAction SilentlyContinue -Depth 5 |
        Where-Object { $_.Name -match 'doomsday|ceymer|prestige|destruct|injector' } | ForEach-Object {
            Add-Finding -Severity 'HIGH' -Category 'Temp Self Destruct File' -Evidence $_.Name -Path $_.FullName
        }

    Write-Host "[i] Scanning Windows Prefetch..." -ForegroundColor Cyan
    $prefetchPath = Join-Path $env:SystemRoot "Prefetch"
    if (Test-Path $prefetchPath) {
        Get-ChildItem -Path $prefetchPath -File -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -match 'DOOMSDAY|CEYMER|PRESTIGE|METEOR|WURST|RISE' } | ForEach-Object {
                Add-Finding -Severity 'HIGH' -Category 'Prefetch Execution Trace' -Evidence $_.Name -Path $_.FullName
            }
    }
}

# ==================== START ====================
Write-Header
Search-SelfDestruct

Write-Host "`n" + ("═" * 100) -ForegroundColor Green

$high = @($script:Findings | Where-Object Severity -eq 'HIGH').Count
$medium = @($script:Findings | Where-Object Severity -eq 'MEDIUM').Count

Write-Host " HIGH   : $high" -ForegroundColor Red
Write-Host " MEDIUM : $medium" -ForegroundColor Yellow
Write-Host

if ($script:Findings.Count -eq 0) {
    Write-Host " [OK] Geen sporen van Doomsday, Ceymer, Prestige of andere self-destruct clients gevonden." -ForegroundColor Green
} else {
    $script:Findings | Sort-Object @{Expression={if($_.Severity -eq 'HIGH') {0} else {1}}} | ForEach-Object {
        $col = if ($_.Severity -eq 'HIGH') { 'Red' } else { 'Yellow' }
        Write-Host "[$($_.Severity)] $($_.Category)" -ForegroundColor $col
        Write-Host "   Evidence : $($_.Evidence)" 
        Write-Host "   Path     : $($_.Path)"
        Write-Host
    }
}

Write-Host ("═" * 100) -ForegroundColor Green
if (-not $NoPause) { Read-Host 'Druk op Enter om af te sluiten' }
