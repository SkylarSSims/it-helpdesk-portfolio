param(
[string]$User = $env:USERNAME,
[string]$OutRoot = "$env:TEMP\triage"
)

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$outDir = Join-Path $OutRoot "account_$timestamp"

New-Item -ItemType Directory -Path $outDir -Force | Out-Null

Write-Output "Collecting account information..."

whoami > "$outDir\current_user.txt"

net user $User > "$outDir\user_details.txt"

net localgroup administrators > "$outDir\administrators_group.txt"

Get-LocalUser | Out-File "$outDir\local_users.txt"

Get-LocalGroup | Out-File "$outDir\local_groups.txt"

Write-Output "Done. Evidence folder: $outDir"