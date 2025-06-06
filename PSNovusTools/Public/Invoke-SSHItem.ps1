<#
.SYNOPSIS
    Executes an SSH command on a remote server using Posh-SSH.
.DESCRIPTION
    Connects to a remote server via SSH, executes a command, and returns the result.
#>
function Invoke-SSHItem {
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
       
        [Parameter(Mandatory = $true, HelpMessage = "Enter the remote SSH command.")]
        [ValidateNotNullOrEmpty()]
        [string]$sshCommand

    )

    process {
        # Check if the script is running with administrative privileges
        if (-not (Get-IsAdministrator)) {
            Write-Error "Please run as administrator."
            return $null
        }

        try {
            $credential = Get-Credential -remoteUser $remoteUser -remotePassword $remotePassword
    
            if (-not $credential) {
                
                return $null
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
                return $null
            }
           $sshresult = Invoke-SSHSessionItem -session $session -sshCommand $sshCommand

        }
        finally {
            # Close the SSH session if it was created
            if ($session) {
                 Close-SSHSession($session)
            }
        }
        return $sshresult
    }
}
