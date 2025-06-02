<#
.SYNOPSIS
Sets secure read-only permissions on a web.config file for a specific IIS AppPool identity.

.DESCRIPTION
This function ensures that the specified AppPool user has read access to the provided web.config file.
It removes any existing access rules for the AppPool user and optional hardens by removing write access for 'Everyone' if it exists.
#>

function Set-IISWebConfigSecurity {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, HelpMessage = "Enter the path to the web.config file to secure.")]
        [string]$FilePath,

        [Parameter(Mandatory = $true, HelpMessage = "Specify the IIS AppPool identity (e.g., 'IIS APPPOOL\\MyAppPool') to grant read access.")]
        [string]$AppPoolUser
    )

    process {
        if (-not (Test-Path -Path $FilePath)) {
            Write-Error "web.config not found at path: $FilePath"
            return $false
        }
    
        # Check if the script is running with administrative privileges
        if (-not (Get-IsAdministrator)) {
            Write-Error "Please run as administrator."
            return $false
        }    

        # Construct AppPool identity
        $identity = "IIS AppPool\$AppPoolUser"
    
        try {
            # Get current ACL
            $acl = Get-Acl -Path $FilePath

            # Remove existing ACEs for AppPool identity if any
            $acl.Access | Where-Object { $_.IdentityReference -eq $identity } | ForEach-Object {
                $acl.RemoveAccessRule($_) | Out-Null
            }
        
            # Create new read-only access rule
            $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
                $identity,
                [System.Security.AccessControl.FileSystemRights]::Read,
                [System.Security.AccessControl.AccessControlType]::Allow
            )
            $acl.AddAccessRule($accessRule)
        
            # Optionally restrict Everyone write access
            $acl.Access | Where-Object { 
                $_.IdentityReference -eq 'Everyone' -and 
                ($_.FileSystemRights -band [System.Security.AccessControl.FileSystemRights]::Write) 
            } | ForEach-Object {
                $acl.RemoveAccessRule($_) | Out-Null
            }
        
            # Set the updated ACL
            Set-Acl -Path $FilePath -AclObject $acl
        
            Write-Verbose "Permissions updated for $identity on $FilePath"
            return $true
        }
        catch {
            Write-Error "Failed to update ACL: $_"
            return $false
        }
    }
}
