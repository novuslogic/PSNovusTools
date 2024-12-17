

$modulePath = "D:\Projects\PSNovusTools\PSNovusTools"
Import-Module -Name $modulePath -Force

$remoteServer = "10.0.0.31"
$remoteUser = "ubuntu"
$remotePassword = Convert-StringToSecureString("password")


$sshBashCommand = 'echo "Hello World"'

$sshresult = Invoke-SSHItemBash -remoteServer $remoteServer -remoteUser $remoteUser -remotePassword $remotePassword -sshBashCommand $sshBashCommand


Write-Output $sshresult.Output