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
    # Set or add properties
    if ($null -eq $profile.fontFace) {
      $profile | Add-Member -MemberType NoteProperty -Name fontFace -Value $FontFace
    } else {
      $profile.fontFace = $FontFace
    }

    if ($null -eq $profile.colorScheme) {
      $profile | Add-Member -MemberType NoteProperty -Name colorScheme -Value $ColorScheme
    } else {
      $profile.colorScheme = $ColorScheme
    }

    if ($null -eq $profile.useAcrylic) {
      $profile | Add-Member -MemberType NoteProperty -Name useAcrylic -Value $UseAcrylic
    } else {
      $profile.useAcrylic = $UseAcrylic
    }

    if ($null -eq $profile.opacity) {
      $profile | Add-Member -MemberType NoteProperty -Name opacity -Value $Opacity
    } else {
      $profile.opacity = $Opacity
    }
  }
}

$json | ConvertTo-Json -Depth 100 | Set-Content $settingsPath
Write-Host "Profile '$ProfileName' updated."
