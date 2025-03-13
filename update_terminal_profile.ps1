param (
  [string]$ProfileName = "",
  [string]$FontFace = "DroidSansMono Nerd Font",
  [string]$ColorScheme = "Dark+",
  [int]$Opacity = 80,
  [bool]$UseAcrylic = $true,
  [string]$User = "root"
)

$settingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

if (-Not (Test-Path $settingsPath)) {
  Write-Host "settings.json not found."
  exit 1
}

$json = Get-Content $settingsPath -Raw | ConvertFrom-Json

foreach ($profile in $json.profiles.list) {
  if ($profile.name -eq $ProfileName) {
    $profile | Add-Member -NotePropertyName fontFace -NotePropertyValue $FontFace -Force
    $profile | Add-Member -NotePropertyName colorScheme -NotePropertyValue $ColorScheme -Force
    $profile | Add-Member -NotePropertyName useAcrylic -NotePropertyValue $UseAcrylic -Force
    $profile | Add-Member -NotePropertyName opacity -NotePropertyValue $Opacity -Force
    $profile | Add-Member -NotePropertyName commandline -NotePropertyValue "wsl -d $ProfileName -u $User --cd ~" -Force
  }
}

$json | ConvertTo-Json -Depth 100 | Out-File -Encoding utf8 $settingsPath
Write-Host "Profile '$ProfileName' updated."
