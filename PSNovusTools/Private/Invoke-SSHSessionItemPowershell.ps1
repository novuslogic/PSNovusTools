function Invoke-SSHSessionItemPowershell([SSH.SshSession]$session, [string]$sshPowershellCommand) {

    $sshCommand = @"
powershell -Command "$sshPowershellCommand"
"@
    
    $sshresult = Invoke-SSHSessionItem -session $session -sshCommand $sshCommand
 

    return $sshresult
}