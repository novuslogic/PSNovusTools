$modulePath = "D:\Projects\PSNovusTools\PSNovusTools"
Import-Module -Name $modulePath -Force

Copy-SSHFile -remoteServer 10.0.0.8 -remoteUser ubuntu -remotePassword (Convert-StringToSecureString("password")) -localFilePath D:\Projects\DevEnv\Ubuntu\scripts\upgrade.sh -remoteFilePath /usr/local/bin/upgrade.sh