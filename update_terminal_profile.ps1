param (
  [string]$ProfileName,
  [string]$FontFace,
  [string]$ColorScheme,
  [int]$Opacity,
  [string]$BackgroundImage,
  [float]$BackgroundImageOpacity,
  [switch]$UseAcrylic,
  [switch]$DisableBell,
  [string]$User
)

$settingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

if (-Not (Test-Path $settingsPath)) {
  Write-Host "settings.json not found."
  exit 1
}

$json = Get-Content $settingsPath -Raw | ConvertFrom-Json

$defaultValues = @{
  'font'                   = @{}
  'colorScheme'            = $null
  'useAcrylic'             = $false
  'opacity'                = 100
  'commandline'            = ""
  'bellStyle'              = $null
  'backgroundImage'        = ""
  'backgroundImageOpacity' = 1
}

foreach ($profile in $json.profiles.list) {
  if ($profile.name -eq $ProfileName) {

    # We generate each json object
    foreach ($key in $defaultValues.Keys) {
      if (-not $profile.$key) {
        $profile | Add-Member -MemberType NoteProperty -Name $key -Value $defaultValues[$key] -Force
      }
    }

    $profile.font.face   = $FontFace
    $profile.colorScheme = $ColorScheme
    $profile.useAcrylic  = $UseAcrylic.IsPresent
    $profile.opacity     = $Opacity
    $profile.commandline = "wsl -d $ProfileName -u $User --cd ~"
    if ($DisableBell.IsPresent) {
      $profile.bellStyle = "none"
    }
    $picturesPath = [Environment]::GetFolderPath("MyPictures")
    $profile.backgroundImage = Join-Path $picturesPath $BackgroundImage
    $profile.backgroundImageOpacity = $BackgroundImageOpacity
  }
}

$json | ConvertTo-Json -Depth 100 | Out-File -Encoding utf8 $settingsPath
Write-Host "Profile '$ProfileName' updated."
