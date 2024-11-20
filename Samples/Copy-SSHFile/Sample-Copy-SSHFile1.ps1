
$module = Get-Module -Name PSNovusTools

if (-not $module) {
    Write-Error "PSNovusTools module is not installed. "
   exit
} 

$remoteServer = "10.0.0.21"
$remoteUser = "Administrator"
$remotePassword = Convert-StringToSecureString("w0rk1ngh@rd")
$localFilePath = "D:\Projects\DevEnv\Ubuntu\scripts\upgrade.sh"
$remoteFilePath = "c:\temp"




Copy-SSHFile -remoteServer $remoteServer -remoteUser $remoteUser -remotePassword $remotePassword -localFilePath $localFilePath -remoteFilePath $remoteFilePath