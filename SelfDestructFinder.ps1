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
    $minecraftPath = Join-Path $env:USERPROFILE "AppData\Roaming\.minecraft"
    $special = @('doomsday','ceymer','prestige')

    Write-Host "[i] Scanning .minecraft..." -ForegroundColor Cyan

    if (Test-Path $minecraftPath) {
        Get-ChildItem -Path $minecraftPath -Recurse -File -ErrorAction SilentlyContinue -Depth 6 | ForEach-Object {
            $name = $_.Name.ToLower()
            $content = ""
            if ($_.Extension -in '.log','.txt','.json','.cfg') {
                $content = Get-Content $_.FullName -Raw -ErrorAction SilentlyContinue
            }

            foreach ($client in $special) {
                if ($name.Contains($client) -or $content -match $client) {
                    Add-Finding -Severity 'HIGH' -Category 'Self Destruct Client' -Evidence $_.Name -Path $_.FullName -Details "Doomsday/Ceymer/Prestige trace"
                }
            }

            if ($name -match 'self.?destruct|autodestruct|destruct|injector|tempcheat' -or $content -match 'selfdestruct') {
                Add-Finding -Severity 'HIGH' -Category 'Self Destruct Remnant' -Evidence $_.Name -Path $_.FullName
            }
        }
    }

    Write-Host "[i] Scanning Temp + Prefetch..." -ForegroundColor Cyan
    Get-ChildItem -Path $env:TEMP, "$env:LOCALAPPDATA\Temp", "$env:SystemRoot\Prefetch" -Recurse -File -ErrorAction SilentlyContinue -Depth 5 | ForEach-Object {
        $name = $_.Name.ToLower()
        if ($name -match 'doomsday|ceymer|prestige|selfdestruct|autodestruct') {
            Add-Finding -Severity 'HIGH' -Category 'Self Destruct Trace' -Evidence $_.Name -Path $_.FullName
        }
    }
}

Write-Header
Search-SelfDestruct

Write-Host "`n" + ("═" * 100) -ForegroundColor Green

$high = @($script:Findings | Where-Object Severity -eq 'HIGH').Count

if ($script:Findings.Count -eq 0) {
    Write-Host " [OK] Geen duidelijke self-destruct sporen gevonden." -ForegroundColor Green
} else {
    Write-Host " HIGH : $high" -ForegroundColor Red
    $script:Findings | Sort-Object Severity -Descending | ForEach-Object {
        Write-Host "[$($_.Severity)] $($_.Category)" -ForegroundColor (if ($_.Severity -eq 'HIGH') {'Red'} else {'Yellow'})
        Write-Host "   Evidence : $($_.Evidence)"
        Write-Host "   Path     : $($_.Path)"
        Write-Host
    }
}

Write-Host ("═" * 100) -ForegroundColor Green
if (-not $NoPause) { Read-Host 'Druk op Enter om af te sluiten' }
