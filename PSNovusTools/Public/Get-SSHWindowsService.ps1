<#
.SYNOPSIS
    Retrieves information about the SSH (sshd) Windows service.

.DESCRIPTION
    The `Get-SSHWindowsService` function fetches details about the OpenSSH SSH Server service (`sshd`) on Windows.
    It provides the service's current status, display name, and other relevant properties.
#>



function Get-SSHWindowsService {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, HelpMessage = "Enter the remote server hostname or IP.")]
        [ValidateNotNullOrEmpty()]
        [string]$remoteServer,

        [Parameter(Mandatory = $true, HelpMessage = "Enter the remote username.")]
        [ValidateNotNullOrEmpty()]
        [string]$remoteUser,

        [Parameter(Mandatory = $true, HelpMessage = "Enter the remote user's password.")]
        [SecureString]$remotePassword,


        [Parameter(Mandatory = $true, HelpMessage = "Enter the remote Windows Servicename.")]
        [String]$remoteServiceName

    )

    process {

  
        try {

            $credential = (New-Object System.Management.Automation.PSCredential($remoteUser,  $remotePassword ))
          
          } catch {
              Write-Error "Failed to create the credential. Error: $_"
   
              return [SSSHWindowsService]::new(0, "","",$false)
          }

        
        # Check if Posh-SSH is installed
        $module = Get-Module -Name Posh-SSH -ListAvailable

        if (-not $module) {
            Write-Host "Posh-SSH module is not installed. Installing now..."
            Install-Module -Name Posh-SSH -Force
        } 
        
        [SSH.SshSession]$session = $null

        # Create a new SSH session
        try {
            $session = New-SSHSession -ComputerName $remoteServer -Credential $credential 
        }
        catch {
            Write-Error "Failed to create SSH session. Error: $_"
            return [SSSHWindowsService]::new(0, "","",$false)
        }

        $SSHRemoteOS = Get-SSHSessionRemoteOS($session)

        if ($SSHRemoteOS.$result -eq $false) {   
            return [SSSHWindowsService]::new(0, "","",$false)
        }

        if ($SSHRemoteOS.$remoteOS -eq "Linux") {
            Write-Error "Remote Linux OS not supported."
            $sshresult = Close-SSHSession($session)
            return [SSSHWindowsService]::new(0, "","",$false)
        }

        if ($SSHRemoteOS.$remoteshell -eq "cmd") {
            Write-Error "Remote shell 'cmd' not supported."
            $sshresult = Close-SSHSession($session)
            return [SSSHWindowsService]::new(0, "","",$false)
        }


        
        try {
            $sshWindowsService = Get-SSHSessionWindowsService -session $session -remoteServiceName $remoteServiceName
        }
        catch {
            Write-Error "Failed to retrieve service information. Error: $_"

            $sshWindowsService = [SSHWindowsService]::new($status, $displayName, $name, $false)
        }
        finally {
            # Close the SSH session
            $sshresult = Close-SSHSession($session)


        }

    return $sshWindowsService;
    }
}
