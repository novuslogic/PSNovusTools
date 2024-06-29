<#
.SYNOPSIS
.DESCRIPTION
#>
function Convert-StringToSecureString
 {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$PlainText
    )

    process {

        try {
            $secureString = ConvertTo-SecureString -String $PlainText -AsPlainText -Force
            return $secureString
        }
        catch {
            Write-Error "Failed to convert plain text to SecureString: $_"
        }

    }
}
