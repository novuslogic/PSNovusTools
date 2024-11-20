<#
.SYNOPSIS
.DESCRIPTION
#>
function Copy-SSHFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$remoteServer,
        [Parameter(Mandatory=$true)]
        [string]$remoteUser,
        [Parameter(Mandatory=$true)]
        [SecureString]$remotePassword,
        [Parameter(Mandatory=$true)]
        [string]$localFilePath,
        [Parameter(Mandatory=$true)]
        [string]$remoteFilePath 
    )

    process {
        # Check if the script is running with administrative privileges
        if (-not (Get-IsAdministrator)) {
            Write-Error "Please run this script as an administrator."
            return $false
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
    Write-Host "Posh-SSH module is not installed. Installing now..."
    Install-Module -Name Posh-SSH -Force
} 


$LocalFilename = Split-Path $localFilePath -Leaf

try {

  $credential = (New-Object System.Management.Automation.PSCredential($remoteUser,  $remotePassword ))

} catch {
    Write-Error "Failed to create the credential. Error: $_"

    return $false
}

try {
  Get-SSHHostKey -ComputerName $remoteServer | New-SSHTrustedHost
}
catch {
    Write-Error "New-SSHTrustedHost. Error: $_"

    return $false
}

# Create a new SSH session
try{
    $session = New-SSHSession -ComputerName $remoteServer -Credential $credential 
  }
  catch {
      Write-Error "Failed to create SSH session. Error: $_"
      return $false
  }

 # Determine the remote OS
 Write-Host "Checking Remote OS detected ..."
 try {
    $osResult = Invoke-SSHCommand -SessionId $session.SessionId -Command 'uname -s'
    if ($osResult.ExitStatus -eq 0) {
        $remoteOS = 'Linux'
        $remoteshell = 'bash'
    } else {
        # If 'uname -s' fails, try a Windows-specific command
        $osResult = Invoke-SSHCommand -SessionId $session.SessionId -Command 'ver'
        if ($osResult.ExitStatus -eq 0) {
            $remoteOS = 'Windows'
            $remoteshell = 'cmd'
        } else {
             # Check for Windows 
            $osResult = Invoke-SSHCommand -SessionId $session.SessionId -Command '$PSVersionTable.OS'
            if ($osResult.ExitStatus -eq 0) {
               $remoteOS = 'Windows'
               $remoteshell = 'powershell'
           } else { 

            Write-Error "Failed to determine the remote OS."
            Remove-SSHSession -SessionId $session.SessionId
            return $false
           }
        }
    }
} catch {
    Write-Error "Error determining remote OS. Error: $_"
    Remove-SSHSession -SessionId $session.SessionId
    return $false
}

if ($remoteshell -eq "cmd") {
    Write-Error "Remote shell 'cmd' not supported."
    Remove-SSHSession -SessionId $session.SessionId
    return $false

}

Write-Host "Remote OS detected: $remoteOS ($remoteshell)"


switch ($remoteOS) {
    "Windows" {
        
        $tmpRemotepath = (Invoke-SSHCommand -SessionId $session.SessionId -Command '$env:TEMP').Output.Trim()

        $tmpSourcePath = (Add-TrailingBackslash($tmpRemotepath)) + $LocalFilename
    }
    "Linux" {
        $tmpRemotepath = "/tmp"
        $tmpSourcePath = "$tmpRemotepath/$LocalFilename"
        
    }
    default {
         Write-Error "Unsupported remote OS: $remoteOS"
         Remove-SSHSession -SessionId $session.SessionId
         return $false
    }
}



try {
   # Set-SCPItem -ComputerName $remoteServer -Credential $credential -Path $localFilePath -Destination /tmp 
  Set-SCPItem -ComputerName $remoteServer -Credential $credential -Path $localFilePath -Destination $tmpRemotepath 
}
catch {
    Write-Error "Failed to copy file. Error: $_"

    return $false
}


switch ($remoteOS) {
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

    Remove-SSHSession -SessionId $session.SessionId

    return $false
}

# Close the SSH session
Remove-SSHSession -SessionId $session.SessionId

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
