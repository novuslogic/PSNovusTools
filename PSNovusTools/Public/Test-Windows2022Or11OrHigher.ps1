<#
.SYNOPSIS
.DESCRIPTION
#>
function Test-Windows2022Or11OrHigher {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false)]
        [switch]$Verbose
    )

    process {
       
            # Get the OS information
            $osInfo = Get-ComputerInfo | Select-Object -Property OsName, WindowsVersion
        
            if ($Verbose) {
                $osInfo | Format-List
            }
        
            # Define minimum version numbers for Windows Server 2022 and Windows 11
            $minWin2022Version = [version]"10.0.20348.0"  # Example version for Windows Server 2022
            $minWin11Version = [version]"10.0.22000.0"    # Example version for Windows 11
        
            # Convert the current OS version to a version object
            $currentVersion = [version]$osInfo.WindowsVersion
        
            # Check if the OS version is greater than or equal to the minimum required version
            if ($currentVersion -ge $minWin2022Version -or $currentVersion -ge $minWin11Version) {
                return $true
            } else {
                return $false
            }

    }
}
