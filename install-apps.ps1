# Ensure non-interactive behavior
$ErrorActionPreference = 'Stop'

# Wait for network (with timeout!)
$timeout = (Get-Date).AddMinutes(10)
do {
    if (Test-NetConnection 8.8.8.8 -InformationLevel Quiet) { break }
    Start-Sleep 10
} while (Get-Date -lt $timeout)

# Ensure winget exists
$winget = "$env:LOCALAPPDATA\Microsoft\WindowsApps\winget.exe"
if (-not (Test-Path $winget)) {
    Write-EventLog -LogName Application -Source Application -EventId 1001 -EntryType Error -Message "Winget not found"
    exit 1
}

$packages = @(
    "Adobe.Acrobat.Reader.64-bit",
    "Google.Chrome",
    "Zoom.Zoom",
    "VideoLAN.VLC"
)

foreach ($pkg in $packages) {
    & $winget install `
        --id $pkg `
        --exact `
        --silent `
        --accept-package-agreements `
        --accept-source-agreements `
        --scope machine
}

# Remove scheduled task after success
Unregister-ScheduledTask -TaskName "InstallApps" -Confirm:$false
