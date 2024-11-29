<#
.SYNOPSIS
    Checks if the operating system is Windows Server 2022, Windows 11, or higher.
.DESCRIPTION
    This function retrieves the current OS version and determines if it meets or exceeds
    the minimum versions for Windows Server 2022 (10.0.20348.0) or Windows 11 (10.0.22000.0).
#>
function Test-Windows2022Or11OrHigher {
    [CmdletBinding()]
    param ()

    process {
        try {
            # Get OS information
            $osInfo = Get-ComputerInfo | Select-Object -Property OsName, WindowsVersion
            
            # Output verbose information
            Write-Verbose "OS Information Retrieved: $($osInfo | Out-String)"

            # Define minimum version numbers for comparison
            $minRequiredVersion = [version]"10.0.20348.0" # Minimum of Windows Server 2022

            # Parse the current OS version
            $currentVersion = [version]$osInfo.WindowsVersion

            Write-Verbose "Current OS Version: $currentVersion"
            Write-Verbose "Minimum Required Version: $minRequiredVersion"

            # Check if the current OS meets or exceeds the minimum version
            if ($currentVersion -ge $minRequiredVersion) {
                return $true
            } else {
                return $false
            }
        } catch {
            Write-Error "An error occurred while retrieving or comparing OS version: $_"
            return $false
        }
    }
}
