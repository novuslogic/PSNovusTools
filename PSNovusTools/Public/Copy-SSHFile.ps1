<#
.SYNOPSIS
    Copies a file from the local system to a remote server using SSH.

.DESCRIPTION
    This function transfers a file to a remote server and places it in the specified location.
    It supports both Linux and Windows servers and dynamically adjusts commands based on the remote OS.
#>

function Copy-SSHFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, HelpMessage = "Enter the remote server hostname or IP.")]
        [ValidateNotNullOrEmpty()]
        [string]$remoteServer,

        [Parameter(Mandatory = $true, HelpMessage = "Enter the remote username.")]
        [ValidateNotNullOrEmpty()]
        [string]$remoteUser,

        [Parameter(Mandatory = $false, HelpMessage = "Enter the remote user's password.")]
        [SecureString]$remotePassword,

        
        [Parameter(Mandatory = $false, HelpMessage = "Enter the specifies a key file path.")]
        [SecureString]$KeyFilePath,


        [Parameter(Mandatory = $true, HelpMessage = "Path to the local file to copy.")]
        [ValidateNotNullOrEmpty()]
        [string]$localFilePath,

        [Parameter(Mandatory = $true, HelpMessage = "Path to the remote destination file.")]
        [ValidateNotNullOrEmpty()]
        [string]$remoteFilePath
    )

    process {
        # Check if the script is running with administrative privileges
        if (-not (Get-IsAdministrator)) {
            Write-Error "Please run as administrator."
            return $false
        }

        if ([string]::IsNullOrWhiteSpace($KeyFilePath) -and [string]::IsNullOrWhiteSpace($remotePassword)) {
            Write-Error "Error: Both KeyFilePath and remotePassword are missing. Provide at least one authentication method."
            return $false
       
        }
        
        if ([string]::IsNullOrWhiteSpace($KeyFilePath) -and -not [string]::IsNullOrWhiteSpace($remotePassword)) {
            Write-Verbose "Using password-based authentication."
        }
        elseif (-not [string]::IsNullOrWhiteSpace($KeyFilePath)) {
            Write-Verbose "Using key-based authentication: $KeyFilePath"
        }
        
$plainTextPassword = Convert-SecureStringToString -SecureString $remotePassword

# Check if the local file exists
if (-not (Test-Path -Path $localFilePath)) {
    Write-Error "File $localFilePath does not exist."
    return $false
}

# Check if Posh-SSH is installed
$module = Get-Module -Name Posh-SSH -ListAvailable

if (-not $module) {
    
    try {
        Write-Host "Posh-SSH module is not installed. Installing now..."
        Install-Module -Name Posh-SSH -Scope CurrentUser -Force -ErrorAction Stop 
    } catch {
        Write-Error "Failed to install Posh-SSH: $_"
        
        return $false
    }
} 

$LocalFilename = Split-Path $localFilePath -Leaf

try {

  $credential = (New-Object System.Management.Automation.PSCredential($remoteUser,  $remotePassword ))

} catch {
    Write-Error "Failed to create the credential. Error: $_"

    return $false
}

try {
    $hostKey = Get-SSHHostKey -ComputerName $remoteServer | New-SSHTrustedHost
}
catch {
    Write-Error "New-SSHTrustedHost. Error: $_"

    return $false
}

# Create a new SSH session
try
    {

    $session = New-SSHSession -ComputerName $remoteServer -Credential $credential 
  }
  catch {
      Write-Error "Failed to create SSH session. Error: $_"
      return $false
  }

$SSHRemoteOS = Get-SSHSessionRemoteOS([SSH.SshSession]$session)

if ($SSHRemoteOS.result -eq $false) {   
   return $false
}

if ($SSHRemoteOS.remoteshell -eq "cmd") {
    Write-Error "Remote shell 'cmd' not supported."
    $sshresult = Close-SSHSession($session)
    return $false
}

switch ($SSHRemoteOS.remoteOS) {
    "Windows" {
        
        $tmpRemotepath = (Invoke-SSHCommand -SessionId $session.SessionId -Command '$env:TEMP').Output.Trim()

        $tmpSourcePath = (Add-TrailingBackslash($tmpRemotepath)) + $LocalFilename
    }
    "Linux" {
        $tmpRemotepath = "/tmp"
        $tmpSourcePath = "$tmpRemotepath/$LocalFilename"
        
    }
    default {
         Write-Error "Unsupported remote OS: $SSHRemoteOS.remoteOS"
         $sshresult = Close-SSHSession($session)
         return $false
    }
}



try {
  Set-SCPItem -ComputerName $remoteServer -Credential $credential -Path $localFilePath -Destination $tmpRemotepath 
}
catch {
    Write-Error "Failed to copy file. Error: $_"

    $sshresult = Close-SSHSession($session)

    return $false
}


switch ($SSHRemoteOS.remoteOS) {
    "Windows" {
        
        $command = "Move-Item -Path '$tmpSourcePath' -Destination '$remoteFilePath' -Force"

    }
    "Linux" {
       # Construct the sudo command with the -S option
      $command = "echo '$plainTextPassword' | sudo -S mv '$tmpSourcePath' '$remoteFilePath'"

    }
    default {
        throw "Unsupported remote OS: $remoteOS"
    }
}

# Execute the command to move the file
try{
  $result = Invoke-SSHCommand -SessionId $session.SessionId -Command $command  
}
catch {
    Write-Error "Failed SSH command. Error: $_"

    $sshresult = Close-SSHSession($session)

    return $false
}

# Close the SSH session
$sshresult = Close-SSHSession($session)

if ($result.ExitStatus -ne 0) {
    Write-Error "Error: Command failed with exit code $($result.ExitStatus)"
    Write-Error "Output: $($result.Output)"
    Write-Error "Error: $($result.Error)"
    return $false
} else {
    return $true
}         
        
    }
}
