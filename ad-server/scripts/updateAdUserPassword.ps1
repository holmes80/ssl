##.\createAdUserWithUpn.ps1 dongjin dongjin word,powerpoint,excel hawaiiantelecom
# Set-ADAccountPassword -Identity dongjin -reset -NewPassword (ConvertTo-SecureString -AsPlainText "holmes80" -Force)
param([string]$username, [string]$newPassword)
$output=Set-ADAccountPassword -Identity $username -reset -NewPassword (ConvertTo-SecureString -AsPlainText $newPassword -Force) -Confirm:$false
$output

