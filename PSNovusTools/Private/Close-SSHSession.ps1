function Close-SSHSession([SSH.SshSession]$session) {

    try{
        $result = Remove-SSHSession -SessionId $session.SessionId 
      }
      catch {
          Write-Error "Failed to close SSH Session."
      
          
      }

      return $result   
}