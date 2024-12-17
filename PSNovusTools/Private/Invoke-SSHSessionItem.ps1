function Invoke-SSHSessionItem([SSH.SshSession]$session, [string]$sshCommand) {

    $sshresult = $null

    try {
       
        # Command to start the service and get its status
        $sshresult = Invoke-SSHCommand -SessionId $session.SessionId -Command $sshCommand
    }
    catch {
        Write-Error "Failed SSH command: $sshCommand Error: $_"
        $sshresult = $null   
    }

    return $sshresult
}