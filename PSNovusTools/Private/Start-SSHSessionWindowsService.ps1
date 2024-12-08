function Start-SSHSessionWindowsService([SSH.SshSession]$session, [string]$remoteServiceName) {
    $status = 0
    $displayName = ""
    $name = ""
    $result = $true

    try {
       
        # Command to start the service and get its status
        $sshCommand = @"
powershell -Command "Start-Service -Name '$remoteServiceName'; Get-Service -Name '$remoteServiceName' | Select-Object Status, DisplayName, Name | ConvertTo-Json"
"@     
        $sshResult = Invoke-SSHCommand -SessionId $session.SessionId -Command $sshCommand
        $serviceInfo = $sshResult.Output | ConvertFrom-Json
          
        # Update service information
        $status = $serviceInfo.Status
        $displayName = $serviceInfo.DisplayName
        $name = $serviceInfo.Name
        if($status -eq 4) {

            $result = true
        }
    }
    catch {
        Write-Error "Failed SSH command: $sshcommand Error: $_"
        $result = $false
          
    }

    return [SSHWindowsService]::new($status, $displayName, $name, $result)
}