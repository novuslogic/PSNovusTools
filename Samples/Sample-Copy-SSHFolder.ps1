


$module = Get-Module -Name PSNovusTools

if (-not $module) {
    Write-Host "PSNovusTools module is not installed. "
   exit
} 

Copy-SSHFolder -remoteServer 10.0.0.21 -remoteUser Administrator -remotePassword (Convert-StringToSecureString("w0rk1ngh@rd")) -localFolderPath "D:\Projects\PSNovusTools\Samples" -remoteFolderPath "c:\temp"