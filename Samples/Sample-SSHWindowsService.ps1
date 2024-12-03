

$modulePath = "D:\Projects\PSNovusTools\PSNovusTools"
Import-Module -Name $modulePath -Force


$remoteServer = "10.0.0.21"
$remoteUser = "Administrator"
$remotePassword = Convert-StringToSecureString("w0rk1ngh@rd")
$remoteServiceName = "docker"


Get-SSHWindowsService -remoteServer $remoteServer -remoteUser $remoteUser -remotePassword $remotePassword -remoteServiceName $remoteServiceName