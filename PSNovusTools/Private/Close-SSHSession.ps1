function Close-SSHSession([SSH.SshSession]$session) {

    try{
        $sshresult = Remove-SSHSession -SessionId $session.SessionId 
      }
      catch {
          Write-Error "Failed to close SSH Session. Error: $_"
      
          
      }

      return $sshresult   
}