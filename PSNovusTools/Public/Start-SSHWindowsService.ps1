<#
.SYNOPSIS
    Starts a Windows service on a remote machine using SSH.
.DESCRIPTION
    This function uses the Posh-SSH module to connect to a remote Windows machine via SSH and start a specified service.
#>
function Start-SSHWindowsService {
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

        [Parameter(Mandatory = $true, HelpMessage = "Enter the remote Windows Service name.")]
        [ValidateNotNullOrEmpty()]
        [string]$remoteServiceName
    )

    process {

        # Check if the script is running with administrative privileges
        if (-not (Get-IsAdministrator)) {
            Write-Error "Please run as administrator."
            return $false
        }

        # Initialize variables
        $status = 0
        $displayName = ""
        $name = $remoteServiceName
        $result = $true
        $session = $null

        try {
            $credential = Get-Credential -remoteUser $remoteUser -remotePassword $remotePassword
    
            if (-not $credential) {
                
                return [SSHWindowsService]::new($status, $displayName, $name, $false)
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
                return [SSSHWindowsService]::new(0, "", "", $false)
            }

            $SSHRemoteOS = Get-SSHSessionRemoteOS($session)

            if ($SSHRemoteOS.result -eq $false) {   
                return [SSSHWindowsService]::new(0, "", "", $false)
            }

            if ($SSHRemoteOS.remoteOS -eq "Linux") {
                Write-Error "Remote Linux OS not supported."
                $sshresult = Close-SSHSession($session)
                return [SSSHWindowsService]::new(0, "", "", $false)
            }

            if ($SSHRemoteOS.remoteshell -eq "cmd") {
                Write-Error "Remote shell 'cmd' not supported."
                $sshresult = Close-SSHSession($session)
                return [SSSHWindowsService]::new(0, "", "", $false)
            }

          
            # Command to start the service and get its status
            $sshWindowsService = Start-SSHSessionWindowsService -session $session -remoteServiceName $remoteServiceName
        
            
        }
        catch {
            Write-Error "Failed to start service '$remoteServiceName' on '$remoteServer'. Error: $_"
      
            $sshWindowsService.result = $false
        }
        finally {
            # Close the SSH session if it was created
            if ($session) {
                $sshresult = Close-SSHSession($session)
            }
        }

        # Return the result as a custom object or class

        return $sshWindowsService


    }
}
