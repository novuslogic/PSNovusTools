<#
.SYNOPSIS
.DESCRIPTION
#>
function Add-TrailingBackslash {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    process {
        # Check if the path is not null or empty
        if ([string]::IsNullOrEmpty($Path)) {
            throw "The path cannot be null or empty."
        }

        # Check if the path already ends with a backslash
        if ($Path -notmatch '\\$') {
            $Path += '\'
        }

        return $Path
    }
}
