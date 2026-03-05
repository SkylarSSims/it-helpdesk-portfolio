<# 
system_info.ps1
Purpose: Collect Windows baseline evidence into a timestamped folder (read-only).
Outputs: OS build, uptime, CPU/RAM, disk usage, top processes, security posture, summary.
#>

[CmdletBinding()]
param(
  [string]$OutRoot = (Join-Path $env:TEMP "triage"),
  [switch]$Zip
)

function Test-IsAdmin {
  try {
    return ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
      ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
  } catch { return $false }
}

function Write-Text($Path, $Text) {
  $Text | Out-File -FilePath $Path -Encoding UTF8 -Force
}

function Run-Cmd($Cmd, $Args, $OutFile) {
  try {
    $output = & $Cmd @Args 2>&1
    $output | Out-File -FilePath $OutFile -Encoding UTF8 -Force
    return $true
  } catch {
    ("ERROR running {0}: {1}" -f $Cmd, $_.Exception.Message) | Out-File -FilePath $OutFile -Encoding UTF8 -Force
    return $false
  }
}

$ts = Get-Date -Format "yyyyMMdd_HHmmss"
$runDir = Join-Path $OutRoot ("baseline_{0}" -f $ts)
New-Item -ItemType Directory -Path $runDir -Force | Out-Null

$isAdmin = Test-IsAdmin

Run-Cmd "systeminfo" @() (Join-Path $runDir "systeminfo.txt") | Out-Null

$os = Get-CimInstance Win32_OperatingSystem
$uptime = (Get-Date) - $os.LastBootUpTime
Write-Text (Join-Path $runDir "uptime.txt") ("Last boot: {0}`nUptime: {1} days {2} hours" -f $os.LastBootUpTime, $uptime.Days, $uptime.Hours)

$cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
$cs  = Get-CimInstance Win32_ComputerSystem
Write-Text (Join-Path $runDir "cpu_ram.txt") ("CPU: {0}`nTotal RAM (GB): {1:N2}" -f $cpu.Name, ($cs.TotalPhysicalMemory/1GB))

Get-PSDrive -PSProvider FileSystem | Select-Object Name,Used,Free,@{n='UsedGB';e={[math]::Round($_.Used/1GB,2)}},@{n='FreeGB';e={[math]::Round($_.Free/1GB,2)}} |
  Out-File (Join-Path $runDir "disk_usage.txt") -Encoding UTF8

Get-Process | Sort-Object CPU -Descending | Select-Object -First 10 Name,CPU |
  Out-File (Join-Path $runDir "top_processes_cpu.txt") -Encoding UTF8

Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 10 Name,@{n='WorkingSetMB';e={[math]::Round($_.WorkingSet/1MB,1)}} |
  Out-File (Join-Path $runDir "top_processes_mem.txt") -Encoding UTF8

Run-Cmd "manage-bde" @("-status") (Join-Path $runDir "bitlocker_status.txt") | Out-Null

try { Get-MpComputerStatus | Out-File (Join-Path $runDir "defender_status.txt") -Encoding UTF8 }
catch { Write-Text (Join-Path $runDir "defender_status.txt") "Defender status unavailable (may require admin)." }

try { Get-NetFirewallProfile | Select-Object Name,Enabled | Out-File (Join-Path $runDir "firewall_profiles.txt") -Encoding UTF8 }
catch { Write-Text (Join-Path $runDir "firewall_profiles.txt") "Firewall status unavailable (may require admin)." }

$summary = @()
$summary += "Windows Baseline Summary"
$summary += ("Timestamp: {0}" -f (Get-Date))
$summary += ("Run folder: {0}" -f $runDir)
$summary += ("Admin: {0}" -f $isAdmin)
$summary += ""
$summary += "Review disk usage, uptime, OS build, and security controls."
$summary += "Escalate if BitLocker/Defender/Firewall violate policy."
if (-not $isAdmin) { $summary += "WARNING: Not running as Administrator. Some data may be incomplete." }

Write-Text (Join-Path $runDir "summary.txt") ($summary -join "`r`n")

if ($Zip) {
  $zipPath = Join-Path $OutRoot ("baseline_{0}.zip" -f $ts)
  if (Test-Path $zipPath) { Remove-Item $zipPath -Force }
  Compress-Archive -Path (Join-Path $runDir "*") -DestinationPath $zipPath -Force
}

Write-Host ("Done. Evidence folder: {0}" -f $runDir)
