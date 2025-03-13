param (
  [string]$ProfileName = "",
  [string]$FontFace = "DroidSansMono Nerd Font Mono",
  [string]$ColorScheme = "Dark+",
  [int]$Opacity = 80,
  [bool]$UseAcrylic = $true
)

$settingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

if (-Not (Test-Path $settingsPath)) {
  Write-Host "settings.json not found."
  exit 1
}

$json = Get-Content $settingsPath -Raw | ConvertFrom-Json

foreach ($profile in $json.profiles.list) {
  if ($profile.name -eq $ProfileName) {
    $profile.fontFace = $FontFace
    $profile.colorScheme = $ColorScheme
    $profile.useAcrylic = $UseAcrylic
    $profile.opacity = $Opacity
  }
}

$json | ConvertTo-Json -Depth 100 | Set-Content $settingsPath
Write-Host "Profile '$ProfileName' updated."

