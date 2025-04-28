# Installing Module

```powershell
$module = Get-Module -Name PSNovusTools 

if (-not $module) {
    Write-Error "PSNovusTools module is not installed. Trying to install ... "

    try {
        Install-Module -Name PSNovusTools -Scope CurrentUser -Force -ErrorAction Stop ##-Verbose
    } catch {
        Write-Error "Failed to install PSNovusTools: $_"
        exit 1
    }
} 
```