<#
.SYNOPSIS
Installs the Windows Package Manager (winget) if it's not already installed.

.DESCRIPTION
#>
function Install-Winget {
    [CmdletBinding()]
    param(

    )

    process {

            # Check if the script is running with administrative privileges
        if (-not (Get-IsAdministrator)) {
            Write-Error "Please run as administrator."
            return $false
        }


        $wingetCommand = Get-Command winget -ErrorAction SilentlyContinue
if ($wingetCommand)
{
    Write-Error "winget is already installed. (Path: $($wingetCommand.Source))" -ForegroundColor Green
    Write-Error "Version: $(winget --version)`n"
    return $false
}
else
{
    Write-Virbose "winget is not installed. Proceeding with installation..." -ForegroundColor Yellow
}

$LatestVersionURL = "https://api.github.com/repos/microsoft/winget-cli/releases/latest"

Write-Verbose "`n--- Downloading the latest DesktopAppInstaller (.msixbundle) ---"

try {
    $LatestRelease = Invoke-RestMethod -Uri $LatestVersionURL -UseBasicParsing
} catch {
    Write-Error "Error: Unable to fetch release info from GitHub. Check your internet connection or GitHub availability." -ForegroundColor Red
    return $false
}

$MsixAsset = $LatestRelease.assets | Where-Object { $_.name -like "*DesktopAppInstaller*msixbundle" }

if (-not $MsixAsset) {
    Write-Error "Error: Could not find .msixbundle asset in the latest GitHub release." 
    return $false
}

$MsixUrl = $MsixAsset.browser_download_url

# Choose a location to save the .msixbundle (Temp folder recommended)
$LocalFile = Join-Path $env:TEMP "DesktopAppInstaller.msixbundle"

Write-Verbose "Downloading from: $MsixUrl"
Write-Host "Saving to     : $LocalFile"

try {
    Invoke-WebRequest -Uri $MsixUrl -OutFile $LocalFile -UseBasicParsing
    Write-Verbose "Download complete."
} catch {
    Write-Error "Error: Failed to download .msixbundle file. $_" 
    return $false
}

Write-Verbose "Installing/Updating winget (App Installer) ---"
try {
    Add-AppxPackage -Path $LocalFile
    Write- "Installation successful."
} catch {
    Write-Error "Error: Installation of the package failed. $_" 

    return $false
}

Write-Verbose "Verifying winget installation ---"
if (Get-Command winget -ErrorAction SilentlyContinue)
{
    Write-Verbose "winget installed successfully. Version: $(winget --version)" -ForegroundColor Green
}
else
{
    Write-Error "Error: winget command not found after installation." 
    return $false

}

# --- 6. Clean up (optional) ---
Write-Verbose "Cleaning up downloaded file..."
Remove-Item $LocalFile -ErrorAction SilentlyContinue
Write-Verbose "Done."


    }
}
