<#
.SYNOPSIS
    Imports and executes a PowerShell script into the current session.

.DESCRIPTION
    The Import-PowerShellScript function imports and executes the contents of a specified PowerShell (.ps1) script file into the current PowerShell session.

.PARAMETER scriptPath
    The scriptPath to the PowerShell script (.ps1 file) to import and execute.

.EXAMPLE
    Import-PowerShellScript -scriptPath ".\script.ps1"

    Imports and runs the script located at .\script.ps1.

#>
function Import-PowerShellScript {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$scriptPath
    )

    process {
        if (-Not (Test-Path $scriptPath)) {
            Write-Error "Script file '$scriptPath' does not exist."
            return $false
        }

        try {
            # Dot-source the script (loads into current scope)
            . $scriptPath

            Write-Verbose "Script loaded successfully."
          }
     catch {
        Write-Error "Failed to load script: $_"
        return $false
     } 
    
     return $true
    }
}
