param([String]$upn) 
$upns=Get-ADForest|select UPNSuffixes
$upnsuffixes=$upns.UPNSuffixes
   if($upnsuffixes -notcontains $upn)
    { 
	write-host "The UPN doesn't exist hence adding UPN:$upn"
       Get-ADForest |Set-ADForest -UPNSuffixes @{Add=$upn}
	write-host "Added $upn"
    }
else
{
Write-host "The UPN $upn already exists."
}