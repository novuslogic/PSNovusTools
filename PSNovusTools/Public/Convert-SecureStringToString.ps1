<#
.SYNOPSIS
.DESCRIPTION
#>
function Convert-SecureStringToString {
    [CmdletBinding()]
    param(
        [System.Security.SecureString]$SecureString
    )

    process {
        $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureString)
        $UnsecureString = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
        [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)
        
        return $UnsecureString
    }
}
