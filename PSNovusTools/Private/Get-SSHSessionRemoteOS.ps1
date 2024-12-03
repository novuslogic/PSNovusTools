class SSHRemoteOS {
    [string]$remoteOS
    [string]$remoteshell   
    [boolean]$result

    SSHRemoteOS([string]$remoteOS, [string]$remoteshell, [boolean]$result) {
        $this.remoteOS = $remoteOS
        $this.remoteshell = $remoteshell   
        $this.result = $result
    }
}


function Get-SSHSessionRemoteOS([SSH.SshSession]$session) {

    try {
        # Attempt to determine the remote OS using SSH commands
        $osCommands = @(
            @{ Command = 'uname -s'; OS = 'Linux'; Shell = 'bash' },
            @{ Command = 'ver'; OS = 'Windows'; Shell = 'cmd' },
            @{ Command = '$PSVersionTable.OS'; OS = 'Windows'; Shell = 'powershell' }
        )
    
        foreach ($osCommand in $osCommands) {
            $osResult = Invoke-SSHCommand -SessionId $session.SessionId -Command $osCommand.Command
            if ($osResult.ExitStatus -eq 0) {
                $remoteOS = $osCommand.OS
                $remoteshell = $osCommand.Shell
                break
            }
        }
    
        if (-not $remoteOS) {
            Write-Error "Failed to determine the remote OS."
            $sshresult = Close-SSHSession $session
            $result = $false
        }

        $result = $true
    } catch {
        Write-Error "Error determining remote OS. Error: $_"
        $sshresult = Close-SSHSession $session
        $result =  $false
    }
    

    return [SSHRemoteOS]::new($remoteOS, $remoteshell,$result)
}