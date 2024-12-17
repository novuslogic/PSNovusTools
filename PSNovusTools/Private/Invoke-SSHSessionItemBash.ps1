function Invoke-SSHSessionItemBash([SSH.SshSession]$session, [string]$plainTextPassword,[string]$sshBashCommand) {

    $sshCommand = "echo '$plainTextPassword' | sudo -S $sshBashCommand"
    
    $sshresult = Invoke-SSHSessionItem -session $session -sshCommand $sshCommand
 

    return $sshresult
}