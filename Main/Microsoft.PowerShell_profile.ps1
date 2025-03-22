### PowerShell Profile Customization
### Version 1.0 - Personalized for New8ie

$debug = $false

# Path untuk menyimpan waktu eksekusi terakhir
$timeFilePath = "$env:USERPROFILE\Documents\PowerShell\LastExecutionTime.txt"

# Interval pembaruan dalam hari (-1 untuk menonaktifkan pembaruan otomatis)
$updateInterval = 7

# Fungsi untuk memperbarui profil dari repositori GitHub pribadi Anda
function Update-Profile {
    try {
        $url = "https://raw.githubusercontent.com/New8ie/PowerShell-Style/main/Microsoft.PowerShell_profile.ps1"
        $oldhash = Get-FileHash $PROFILE -Algorithm SHA256
        Invoke-RestMethod $url -OutFile "$env:temp/Microsoft.PowerShell_profile.ps1"
        $newhash = Get-FileHash "$env:temp/Microsoft.PowerShell_profile.ps1" -Algorithm SHA256
        if ($newhash.Hash -ne $oldhash.Hash) {
            Copy-Item -Path "$env:temp/Microsoft.PowerShell_profile.ps1" -Destination $PROFILE -Force
            Write-Host "Profile has been updated. Please restart your shell to apply changes." -ForegroundColor Magenta
        } else {
            Write-Host "Profile is already up-to-date." -ForegroundColor Green
        }
    } catch {
        Write-Error "Failed to update profile: $_"
    } finally {
        Remove-Item "$env:temp/Microsoft.PowerShell_profile.ps1" -ErrorAction SilentlyContinue
    }
}

# Mengecek apakah perlu melakukan update profil
if (-not $debug -and `
    ($updateInterval -eq -1 -or `
    -not (Test-Path $timeFilePath) -or `
    ((Get-Date) - [datetime]::ParseExact((Get-Content -Path $timeFilePath), 'yyyy-MM-dd', $null)).TotalDays -gt $updateInterval)) {

    Update-Profile
    (Get-Date -Format 'yyyy-MM-dd') | Out-File -FilePath $timeFilePath
} else {
    Write-Warning "Profile update skipped. Last update check was within the last $updateInterval day(s)."
}

# Fungsi untuk membersihkan cache
                    function Clear-Cache {
    Write-Host "Clearing cache..." -ForegroundColor Cyan
    Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "$env:SystemRoot\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "$env:LOCALAPPDATA\Microsoft\Windows\INetCache\*" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "Cache clearing completed." -ForegroundColor Green
}

# Fungsi kustom tambahan
function Open-WorkFolder {
    Start-Process explorer.exe "$env:USERPROFILE\Documents\Work"
}

function Open-DevTools {
    Start-Process "C:\Program Files\Microsoft VS Code\Code.exe"
}

Write-Host "Custom PowerShell Profile Loaded!" -ForegroundColor Cyan
