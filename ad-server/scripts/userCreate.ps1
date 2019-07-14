
param([string[]]$userPrefix,[string[]]$password1,[string[]]$apps1)
    $arr = new-object System.Collections.arrayList
    $user=$userPrefix.split(",")
    $user
    $password=$password1.split(",")
    $apps=$apps1 -join ','
    $adUser=Get-ADUser -Filter *
    $adUser=$adUser[0].DistinguishedName.split(',')
    $DC1=$adUser[2]
    $DC2=$adUser[3]
    $path= "CN=Users"+","+$DC1+","+$DC2
    $domainName=$DC1.split("=")
    $domainName=$domainName[1]
    $domain=$DC2.split("=")
    $domain=$domain[1]
    $domainName=$domainName+"."+$domain
    #$user  | forEach{
    if($user.count -eq 1)
    {
    $passwordString=$password.ToString();
    $userprincipalname = $user + "@"+$domainName
    $output=New-ADUser -SamAccountName $_.SamAccountName -UserPrincipalName  $userprincipalname -Name $user -DisplayName $user -EmployeeID $employeeId -Description $apps -GivenName $user -SurName " " -Path $path -AccountPassword (ConvertTo-SecureString $passwordString -AsPlainText -force) -Enabled $True -PasswordNeverExpires $True -PassThru 
    $object = New-Object -TypeName PSObject
    $object | Add-Member -Name 'userName' -MemberType Noteproperty -Value $output.GivenName
    $arr+=$object
}
elseif($user.count -gt 1)
{
for($i=0;$i -lt $user.count;$i++){
    $passwordString=$password[$i].ToString();
    $userprincipalname = $user[$i] + "@"+$domainName
    $output=New-ADUser -SamAccountName $_.SamAccountName -UserPrincipalName  $userprincipalname -Name $user[$i] -DisplayName $user[$i] -GivenName $user[$i] -SurName " " -Path $path -AccountPassword (ConvertTo-SecureString $passwordString -AsPlainText -force) -Enabled $True -PasswordNeverExpires $True -PassThru 
    $object = New-Object -TypeName PSObject
    $object | Add-Member -Name 'userName' -MemberType Noteproperty -Value $output.GivenName
    $arr+=$object
 
}
}

$usersfinal=$arr | ConvertTo-Json
return $usersfinal


#Invoke-Command -ComputerName app0 -ScriptBlock {C:\shortcutcopy.ps1 "applications" "$userPrefix"}
