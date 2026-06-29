param([switch]$NoPause)

$ErrorActionPreference = 'SilentlyContinue'
$script:Findings = New-Object System.Collections.Generic.List[object]
$script:Now = Get-Date
$script:LogFile = "$env:USERPROFILE\Desktop\SelfDestruct_Scan_Result.txt"

function Write-Header {

    # Grote bold letters
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

function Write-ProgressBar {
    param([int]$Percent)
    $width = 60
    $filled = [math]::Floor(($Percent / 100) * $width)
    $empty = $width - $filled
    $bar = ('█' * $filled) + ('░' * $empty)
    Write-Host ("`r[ {0} ] {1,3}%" -f $bar, $Percent) -ForegroundColor Green -NoNewline
    if ($Percent -ge 100) { Write-Host }
}

# Rest van de code (zelfde als vorige versie met filters)
function Add-Finding {
    param([string]$Severity, [string]$Category, [string]$Evidence, [string]$Path)
    $script:Findings.Add([pscustomobject]@{
        Severity = $Severity
        Category = $Category
        Evidence = $Evidence
        Path = $Path
    })
}

function Is-OwnTool {
    param([string]$Path)
    if ([string]::IsNullOrEmpty($Path)) { return $false }
    $lower = $Path.ToLower()
    $badWords = @("finder","detector","scanner","fucker","injectorscanner","selfdestructfinder","englishwords","passwords","password","fucker.exe")
    foreach ($word in $badWords) {
        if ($lower.Contains($word)) { return $true }
    }
    return $false
}

function Search-SelfDestruct {
    Write-ProgressBar -Percent 30
    $mcPath = Join-Path $env:USERPROFILE "AppData\Roaming\.minecraft"

    if (Test-Path $mcPath) {
        Get-ChildItem -Path $mcPath -Recurse -File -ErrorAction SilentlyContinue -Depth 6 | ForEach-Object {
            if (Is-OwnTool $_.FullName) { return }
            $content = ""
            if ($_.Extension -in '.log','.txt') {
                $content = Get-Content $_.FullName -Raw -ErrorAction SilentlyContinue
            }
            if ($content -match '(?i)self.?destruct|autodestruct|destruct|prestige.*destruct') {
                Add-Finding -Severity 'HIGH' -Category 'Self Destruct Trace' -Evidence $_.Name -Path $_.FullName
            }
        }
    }

    Write-ProgressBar -Percent 70
    Get-ChildItem -Path $env:TEMP, "$env:LOCALAPPDATA\Temp" -Recurse -File -ErrorAction SilentlyContinue -Depth 5 | ForEach-Object {
        if (Is-OwnTool $_.FullName) { return }
        if ($_.Name -match '(?i)selfdestruct|autodestruct|destruct|prestige') {
            Add-Finding -Severity 'HIGH' -Category 'Self Destruct Temp File' -Evidence $_.Name -Path $_.FullName
        }
    }

    Write-ProgressBar -Percent 100
}

Write-Header
Search-SelfDestruct

"Self Destruct Scan Result - $($script:Now)" | Out-File $script:LogFile
"================================================================" | Out-File $script:LogFile -Append

Write-Host "`n" + ("═" * 100) -ForegroundColor Green

if ($script:Findings.Count -eq 0) {
    Write-Host " [OK] Geen duidelijke self-destruct sporen gevonden." -ForegroundColor Green
} else {
    $high = @($script:Findings | Where-Object Severity -eq 'HIGH').Count
    Write-Host " HIGH : $high" -ForegroundColor Red

    $script:Findings | Sort-Object Severity -Descending | ForEach-Object {
        Write-Host "[$($_.Severity)] $($_.Category)" -ForegroundColor Red
        Write-Host "   Evidence : $($_.Evidence)" 
        Write-Host "   Path     : $($_.Path)"
        Write-Host
    }
}

Write-Host ("═" * 100) -ForegroundColor Green
Write-Host "Resultaten opgeslagen in: $script:LogFile" -ForegroundColor Green
if (-not $NoPause) { Read-Host 'Druk op Enter om af te sluiten' }
