
$modulePath = "D:\Projects\PSNovusTools\PSNovusTools"
Remove-Module -Name $modulePath -Force
Import-Module -Name $modulePath -Force

Copy-SSHFolder -remoteServer 10.0.0.21 -remoteUser Administrator -remotePassword (Convert-StringToSecureString("w0rk1ngh@rd")) -localFolderPath "D:\Projects\PSNovusTools\Samples" -remoteFolderPath "c:\temp" -Verbose