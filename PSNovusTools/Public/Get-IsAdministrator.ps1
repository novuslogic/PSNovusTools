<#
.SYNOPSIS
.DESCRIPTION
#>
function Get-IsAdministrator {
    [CmdletBinding()]
    param(

    )

    process {
        try {
            $currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()
            $principal = New-Object System.Security.Principal.WindowsPrincipal($currentUser)
            $isAdmin = $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
            return $isAdmin
        }
        catch {
            Write-Error "An error occurred: $_"
            return $false
        }
    }
    
}
