param([string]$username)

 try{
      $user=Remove-ADUser -Identity $username -Confirm:$false
      $user
      # Delete the user.
      # Remove-ADUser -Identity $ADUser.sAMAccountName
    }catch{
      Write-host($user,'is not existing. Cannot be deleted')
    }