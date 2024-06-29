<#
.SYNOPSIS
.DESCRIPTION
#>
function Get-WindowsTempFolder {
    [CmdletBinding()]
    param(

    )

    process {
        try {
            $tempFolder = [System.IO.Path]::GetTempPath()
         
            return $tempFolder
        }
        catch {
            Write-Error "Failed to get the temporary folder path: $_"
        }

    }
}
