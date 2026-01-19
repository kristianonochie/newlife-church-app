# PowerShell helper to generate an Android keystore for signing
# Usage: Open PowerShell as Administrator and run:
#   .\generate_keystore.ps1 -OutPath "$env:USERPROFILE\\.android\\my-release-key.jks" -Alias newlife_key

param(
    [string]$OutPath = "$env:USERPROFILE\\.android\\my-release-key.jks",
    [string]$Alias = 'newlife_key'
)

Write-Host "Generating keystore at: $OutPath"

if (-Not (Test-Path (Split-Path $OutPath))) {
    New-Item -ItemType Directory -Path (Split-Path $OutPath) -Force | Out-Null
}

& keytool -genkeypair -v -keystore $OutPath -alias $Alias -keyalg RSA -keysize 2048 -validity 10000

Write-Host "Keystore generation complete. Please create android/keystore.properties with your passwords and storeFile path."
