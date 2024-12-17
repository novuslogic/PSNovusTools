

$modulePath = "D:\Projects\PSNovusTools\PSNovusTools"
Import-Module -Name $modulePath -Force

$remoteServer = "10.0.0.21"
$remoteUser = "Administrator"
$remotePassword = Convert-StringToSecureString("w0rk1ngh@rd")


$sshPowershellCommand = "Write-Output 'Hello World'"


$sshresult = Invoke-SSHItemPowershell -remoteServer $remoteServer -remoteUser $remoteUser -remotePassword $remotePassword -sshPowershellCommand $sshPowershellCommand


Write-Output $sshresult.Output