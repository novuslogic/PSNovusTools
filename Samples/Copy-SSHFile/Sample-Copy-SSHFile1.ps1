
$module = Get-Module -Name PSNovusTools

if (-not $module) {
    Write-Host "PSNovusTools module is not installed. "
   exit
} 

$remoteServer = "10.0.0.24"
$remoteUser = "ubuntu"
$remotePassword = Convert-StringToSecureString("password")
$localFilePath = "D:\Projects\DevEnv\Ubuntu\scripts\upgrade.sh"
$remoteFilePath = "/usr/local/bin/upgrade.sh"




Copy-SSHFile -remoteServer $remoteServer -remoteUser $remoteUser -remotePassword $remotePassword -localFilePath $localFilePath -remoteFilePath $remoteFilePath