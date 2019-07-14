#Written by Dongjin Suh (dongjin.suha@stratussilverlining.com)
#Input : array of username divided by comma
# ex : ./multipleUserDelete.ps1 user1,user2,user3,user4
param([string[]]$username)

$users=$username.split(",")
#$users = $username -join ','
#$users
#$users.count

ForEach ($user in $users)
{
    # Retrieve user to make sure they exist.
   # $ADUser = Get-ADUser -Identity $user
    #If ($ADUser)               
    try{
         # Delete the user.
        $output=Remove-ADUser -Identity $user -Confirm:$false
        Write-host($user,'is successfully deleted from AD')       
        # Remove-ADUser -Identity $ADUser.sAMAccountName
    }catch{
        Write-host($user,'is not existing in AD. Cannot be deleted')
    }

}