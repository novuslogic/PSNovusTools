<#
.SYNOPSIS
    Secures a remote IIS web.config file over SSH by setting read-only permissions for a specified IIS AppPool identity.

.DESCRIPTION
    The Set-SSHIISWebConfigSecurity function connects to a remote Windows server using SSH and invokes the Set-IISWebConfigSecurity function on that server. 
    It ensures that a specified IIS AppPool user has read access to the given web.config file and that unnecessary write permissions are removed for enhanced security.
    This function uses the Posh-SSH module to establish the SSH session and execute the required PowerShell commands remotely.
 #>   


function Set-SSHIISWebConfigSecurity {
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
       

        [Parameter(Mandatory = $true, HelpMessage = "Enter the path to the web.config file to secure.")]
        [string]$FilePath,
 
        [Parameter(Mandatory = $true, HelpMessage = "Specify the IIS AppPool identity (e.g., 'IIS APPPOOL\\MyAppPool') to grant read access.")]
        [string]$AppPoolUser

    )

    process {
        if (-not (Get-IsAdministrator)) {
            Write-Error "Please run as administrator."
            return $null
        }

        # Convert SecureString password for Posh-SSH
        $plainPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
            [Runtime.InteropServices.Marshal]::SecureStringToBSTR($remotePassword)
        )
        $credential = New-Object System.Management.Automation.PSCredential($remoteUser, $remotePassword)

        # Ensure Posh-SSH module
        if (-not (Get-Module -ListAvailable -Name Posh-SSH)) {
            Write-Host "Installing Posh-SSH module..."
            Install-Module -Name Posh-SSH -Scope CurrentUser -Force
        }

        Import-Module Posh-SSH

        $session = $null
        try {
            $session = New-SSHSession -ComputerName $remoteServer -Credential $credential
            if (-not $session) { throw "Failed to establish SSH session." }

            # Prepare PowerShell command as a string to run on remote
            $psCmd = @"
if (-not (Get-Command Set-IISWebConfigSecurity -ErrorAction SilentlyContinue)) {
    throw 'Set-IISWebConfigSecurity function not found on remote machine.'
}
Set-IISWebConfigSecurity -FilePath '$FilePath' -AppPoolUser '$AppPoolUser'
"@

           

            $result = Invoke-SSHCommand -SessionId $session.SessionId -Command "powershell -NoProfile -Command `$ErrorActionPreference = 'Stop'; $psCmd"

            # Output result text
            $result.Output
        }
        finally {
            if ($session) { Remove-SSHSession -SessionId $session.SessionId }
        }
    }
}
