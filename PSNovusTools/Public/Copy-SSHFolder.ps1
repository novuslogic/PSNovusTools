<#
.SYNOPSIS
    Copies files and folders from a local path to a remote path using SSH.

.DESCRIPTION
    This function allows recursive copying of files and folders from a local system
    to a remote system using SSH. It dynamically adapts based on the remote operating system.
#>
function Copy-SSHFolder {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, HelpMessage = "Enter the remote server hostname or IP.")]
        [ValidateNotNullOrEmpty()]
        [string]$remoteServer,

        [Parameter(Mandatory = $true, HelpMessage = "Enter the remote username.")]
        [ValidateNotNullOrEmpty()]
        [string]$remoteUser,

        [Parameter(Mandatory = $true, HelpMessage = "Enter the remote user's password.")]
        [SecureString]$remotePassword,

        [Parameter(Mandatory = $true, HelpMessage = "Path to the local folder to copy.")]
        [ValidateNotNullOrEmpty()]
        [string]$localFolderPath,

        [Parameter(Mandatory = $true, HelpMessage = "Path to the remote destination folder.")]
        [ValidateNotNullOrEmpty()]
        [string]$remoteFolderPath
    )

    process {
        # Check for administrative privileges
        if (-not (Get-IsAdministrator)) {
            Write-Error "Please run as administrator."
            return $false
        }

        # Validate local folder path
        if (-not (Test-Path -Path $localFolderPath)) {
            Write-Error "Local folder '$localFolderPath' does not exist."
            return $false
        }

        # Ensure Posh-SSH is installed
        if (-not (Get-Module -Name Posh-SSH -ListAvailable)) {
            Write-Host "Installing Posh-SSH module..."
            Install-Module -Name Posh-SSH -Force
        }

        # Create credentials
        try {
            $credential = New-Object System.Management.Automation.PSCredential($remoteUser, $remotePassword)
        } catch {
            Write-Error "Failed to create credentials. Error: $_"
            return $false
        }

        # Establish SSH session
        try {
            $session = New-SSHSession -ComputerName $remoteServer -Credential $credential
        } catch {
            Write-Error "Failed to establish SSH session. Error: $_"
            return $false
        }

        # Determine remote OS
        try {
            $osCheck = Invoke-SSHCommand -SessionId $session.SessionId -Command 'uname -s' -ErrorAction Stop
            $remoteOS = if ($osCheck.ExitStatus -eq 0) { "Linux" } else { "Windows" }
        } catch {
            Write-Error "Unable to determine remote OS. Error: $_"
            Close-SSHSession $session
            return $false
        }

        # Ensure the destination folder exists on the remote system
        $createFolderCommand = if ($remoteOS -eq "Linux") {
            "mkdir -p '$remoteFolderPath'"
        } else {
            "if (-not (Test-Path '$remoteFolderPath')) { New-Item -ItemType Directory -Path '$remoteFolderPath' }"
        }

        try {
            Invoke-SSHCommand -SessionId $session.SessionId -Command $createFolderCommand
        } catch {
            Write-Error "Failed to create remote folder. Error: $_"
            Close-SSHSession $session
            return $false
        }

        # Copy local folder to remote folder
        try {
            # Recursively copy all files and folders using SCP
            $localFolderContent = Get-ChildItem -Path $localFolderPath -Recurse -File
            foreach ($file in $localFolderContent) {
                # Calculate the relative path
                $relativePath = $file.FullName.Substring($localFolderPath.Length).TrimStart('\')


                $remoteFilePath = (Join-Path -Path $remoteFolderPath -ChildPath $relativePath)

                # Create remote directory if it doesn't exist
                $createDirCommand = if ($remoteOS -eq "Linux") {
                    $remoteDir = (Split-Path -Path $remoteFilePath).Replace("\", "/")
                    "mkdir -p '$remoteDir'"
                } else {
                    $remoteDir = (Split-Path -Path $remoteFilePath)
                    "if (-not (Test-Path '$remoteDir')) { New-Item -ItemType Directory -Path '$remoteDir' }"
                }

                Invoke-SSHCommand -SessionId $session.SessionId -Command $createDirCommand

                # Transfer the file
                #Set-SCPItem -SessionId $session.SessionId -Path  -Destination 
                Set-SCPItem -ComputerName $remoteServer -Credential $credential -Path $file.FullName -Destination $remoteDir
            }
        } catch {
            Write-Error "Failed to copy folder contents. Error: $_"
            Close-SSHSession $session
            return $false
        }

        # Close SSH session
        Close-SSHSession $session
        #Write-Host "Folder copied successfully to $remoteFolderPath"
        return $true
    }
}
