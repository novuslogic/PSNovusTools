function Invoke-SSHSessionCommand([SSH.SshSession]$session, [string]$sshCommand) {

    $sshResult = $null

    try {
       
        # Command to start the service and get its status
        $sshResult = Invoke-SSHCommand -SessionId $session.SessionId -Command $sshCommand
    }
    catch {
        Write-Error "Failed SSH command: $sshCommand Error: $_"
        $sshResult = $null   
    }

    return $sshResult
}