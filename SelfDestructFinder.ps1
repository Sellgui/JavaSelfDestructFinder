param(
  [switch]$NoPause
)

$ErrorActionPreference = 'SilentlyContinue'
$script:Findings = New-Object System.Collections.Generic.List[object]
$script:Now = Get-Date
$script:ToolRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$script:ScanStartedAt = Get-Date
$script:MaxScanSeconds = 120

function Test-TimeBudget {
  return (((Get-Date) - $script:ScanStartedAt).TotalSeconds -lt $script:MaxScanSeconds)
}

# ==================== GROTE VERTICALE BANNER ====================
function Write-Header {
  Clear-Host
  Write-Host "╔════════════════════════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
  Write-Host "║" -ForegroundColor Green -NoNewline
  Write-Host "          MINECRAFT CHEAT SCANNER          " -ForegroundColor White -NoNewline
  Write-Host "║" -ForegroundColor Green
  Write-Host "╚════════════════════════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Green
  Write-Host

  # Minecraft ASCII
  Write-Host " ███╗   ███╗██╗███╗   ██╗███████╗ ██████╗██████╗  █████╗ ███████╗████████╗" -ForegroundColor Green
  Write-Host " ████╗ ████║██║████╗  ██║██╔════╝██╔════╝██╔══██╗██╔══██╗██╔════╝╚══██╔══╝" -ForegroundColor Green
  Write-Host " ██╔████╔██║██║██╔██╗ ██║█████╗  ██║     ██████╔╝███████║█████╗     ██║   " -ForegroundColor Green
  Write-Host " ██║╚██╔╝██║██║██║╚██╗██║██╔══╝  ██║     ██╔══██╗██╔══██║██╔══╝     ██║   " -ForegroundColor Green
  Write-Host " ██║ ╚═╝ ██║██║██║ ╚████║███████╗╚██████╗██║  ██║██║  ██║██║        ██║   " -ForegroundColor Green
  Write-Host " ╚═╝     ╚═╝╚═╝╚═╝  ╚═══╝╚══════╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝        ╚═╝   " -ForegroundColor Green
  Write-Host

  # SELF DESTRUCT DETECTOR - Verticaal gestapeld
  Write-Host "  ███████╗███████╗██╗     ███████╗" -ForegroundColor Green
  Write-Host "  ██╔════╝██╔════╝██║     ██╔════╝" -ForegroundColor Green
  Write-Host "  ███████╗█████╗  ██║     █████╗  " -ForegroundColor Green
  Write-Host "  ╚════██║██╔══╝  ██║     ██╔══╝  " -ForegroundColor Green
  Write-Host "  ███████║███████╗███████╗███████╗" -ForegroundColor Green
  Write-Host "  ╚══════╝╚══════╝╚══════╝╚══════╝" -ForegroundColor Green
  Write-Host " " -ForegroundColor Green
  Write-Host "  ██████╗ ███████╗███████╗████████╗██████╗ ██╗   ██╗ ██████╗████████╗" -ForegroundColor Green
  Write-Host "  ██╔══██╗██╔════╝██╔════╝╚══██╔══╝██╔══██╗██║   ██║██╔════╝╚══██╔══╝" -ForegroundColor Green
  Write-Host "  ██║  ██║█████╗  ███████╗   ██║   ██████╔╝██║   ██║██║        ██║   " -ForegroundColor Green
  Write-Host "  ██║  ██║██╔══╝  ╚════██║   ██║   ██╔══██╗██║   ██║██║        ██║   " -ForegroundColor Green
  Write-Host "  ██████╔╝███████╗███████║   ██║   ██║  ██║╚██████╔╝╚██████╗   ██║   " -ForegroundColor Green
  Write-Host "  ╚═════╝ ╚══════╝╚══════╝   ╚═╝   ╚═╝  ╚═╝ ╚═════╝  ╚═════╝   ╚═╝   " -ForegroundColor Green
  Write-Host " " -ForegroundColor Green
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

# ==================== REST VAN DE TOOL (scan + resultaten) ====================
function Write-ProgressBar {
  param([int]$Percent, [string]$Status)
  $width = 50
  $filled = [math]::Floor(($Percent / 100) * $width)
  $empty = $width - $filled
  $bar = ('█' * $filled) + ('░' * $empty)
  Write-Host ("`r[ {0} ] {1,3}% {2}" -f $bar, $Percent, $Status) -ForegroundColor Green -NoNewline
  if ($Percent -ge 100) { Write-Host }
}

function Add-Finding {
  param([ValidateSet('HIGH','MEDIUM','LOW')][string]$Severity, [string]$Category, [string]$Evidence, [string]$Path = '', [Nullable[datetime]]$ModifiedAt = $null)
  $script:Findings.Add([pscustomobject]@{
    Severity = $Severity
    Category = $Category
    Evidence = $Evidence
    Path = $Path
    ModifiedAt = $ModifiedAt
  }) | Out-Null
}

function Search-MinecraftCheats {
  $minecraftPath = Join-Path $env:USERPROFILE "AppData\Roaming\.minecraft"
  $cheats = @('meteor','wurst','impact','aristois','rise','future','inertia','baritone','bleach','lambda','pyro','konas','liquidbounce','vape')

  if (Test-Path $minecraftPath) {
    Get-ChildItem -Path $minecraftPath -Recurse -File -ErrorAction SilentlyContinue -Depth 6 |
      Where-Object { $_.Extension -in '.jar','.log','.json','.cfg','.txt' } |
      ForEach-Object {
        $name = $_.Name.ToLower()
        foreach ($c in $cheats) {
          if ($name.Contains($c)) {
            $sev = if ($c -in @('meteor','rise','future','wurst','aristois')) {'HIGH'} else {'MEDIUM'}
            Add-Finding -Severity $sev -Category 'Cheat Client Remnant' -Evidence $_.Name -Path $_.FullName -ModifiedAt $_.LastWriteTime
          }
        }
        if ($name -match 'self.?destruct|autodestruct|destruct|injector') {
          Add-Finding -Severity 'HIGH' -Category 'Self Destruct Remnant' -Evidence $_.Name -Path $_.FullName -ModifiedAt $_.LastWriteTime
        }
      }
  }
}

# ==================== START ====================
Write-Header
Write-ProgressBar -Percent 0 -Status 'Scanning for self-destruct cheats...'
Search-MinecraftCheats
Write-ProgressBar -Percent 100 -Status 'Scan complete'

Write-Host "`n" + ("=" * 100) -ForegroundColor Green

$high = @($script:Findings | Where-Object Severity -eq 'HIGH').Count
$medium = @($script:Findings | Where-Object Severity -eq 'MEDIUM').Count

Write-Host " HIGH   : $high" -ForegroundColor Red
Write-Host " MEDIUM : $medium" -ForegroundColor Yellow
Write-Host

if ($script:Findings.Count -eq 0) {
  Write-Host " Geen self-destruct cheat remnants gevonden." -ForegroundColor Green
} else {
  $script:Findings | Sort-Object @{Expression={if($_.Severity -eq 'HIGH') {0} else {1}}} | ForEach-Object {
    $col = if ($_.Severity -eq 'HIGH') {'Red'} else {'Yellow'}
    Write-Host "[$($_.Severity)] $($_.Category)" -ForegroundColor $col
    Write-Host "   Evidence : $($_.Evidence)"
    if ($_.Path) { Write-Host "   Path     : $($_.Path)" }
    if ($_.ModifiedAt) { Write-Host "   Modified : $($_.ModifiedAt)" }
    Write-Host
  }
}

Write-Host ("=" * 100) -ForegroundColor Green
if (-not $NoPause) { Read-Host 'Druk op Enter om af te sluiten' }
