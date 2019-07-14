## Set-AdUser -Identity dongjin -Description 'chrome,firefox'
param([string]$username,[string[]]$appList)  

$apps=$appList -join ','
$output=Set-ADUser -Identity $username -Description $apps # -Confirm:$false  
$output
