class SSHWindowsService {
    [int]$status
    [string]$displayName  
    [string]$name
    [Boolean]$result

    SSHWindowsService([int]$status, [string]$DisplayName, [string]$Name, [Boolean]$result) {
        $this.status = $status
        $this.displayName = $displayName   
        $this.name = $name
        $this.result = $result
    }
}

function Get-SSHSessionWindowsService([SSH.SshSession]$session, [string]$remoteServiceName) {
    $status = 0
    $displayName = ""
    $name = ""
    $result = $true

    try {
       
        $sshcommand = "powershell -Command `"Get-Service -Name '$remoteServiceName' | Select-Object Status, DisplayName, Name | ConvertTo-Json`""

        # Invoke the command on the remote server
        $sshresult = Invoke-SSHCommand -SessionId $session.SessionId -Command $sshcommand

        $serviceInfo = $sshresult.Output | ConvertFrom-Json
        $status = $serviceInfo.Status
        $displayName = $serviceInfo.DisplayName
        $name = $serviceInfo.Name

    }
    catch {
        Write-Error "Failed SSH command: $sshcommand Error: $_"
        $result = $false
          
    }

    return [SSHWindowsService]::new($status, $displayName, $name, $result)

}