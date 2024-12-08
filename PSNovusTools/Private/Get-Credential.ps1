function Get-Credential([string]$remoteUser, [SecureString]$remotePassword) {
    $credential = $null
    
    try {

        $credential = (New-Object System.Management.Automation.PSCredential($remoteUser, $remotePassword ))
      
    }
    catch {
        Write-Error "Failed to create the credential. Error: $_"
    }
   
    return  $credential;
}