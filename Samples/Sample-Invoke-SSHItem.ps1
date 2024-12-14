

$modulePath = "D:\Projects\PSNovusTools\PSNovusTools"
Import-Module -Name $modulePath -Force

$remoteServer = "10.0.0.21"
$remoteUser = "Administrator"
$remotePassword = Convert-StringToSecureString("w0rk1ngh@rd")
$remoteServiceName = "docker"

$sshCommand = @"
powershell -Command "Write-Output 'Hello World'"
"@

$sshresult = Invoke-SSHItem -remoteServer $remoteServer -remoteUser $remoteUser -remotePassword $remotePassword -sshCommand $sshCommand


Write-Output $sshresult.Output