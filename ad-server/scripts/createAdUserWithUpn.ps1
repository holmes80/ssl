<#
.Synopsis
This powershell script is used to create ADUser with their desired domain.
Example: "user1@something.com"   

.Description
This PS Script fetches the UPN's in the trusted host of the Active Directory. If the UPN specified doesn't exist it adds the UPN to the trusted hosts and then creates the user with that UPN(domain).

.Input
Params such as "userprefix", "password", "apps" and "upn" has to be passed to the script.
Example: createAdUserWithUpn.ps1 -userprefix user1 -password1 mobilenerd@1 -apps1 office365basic,office365premium,chrome,notepad++ -upn google.com

.Output
creates the ADUser with their desired domain.

.Notes
Name: createAdUserWithUpn
Author: Automation team
Owner: Mobilenerd

#>
param([string[]]$userPrefix,[string[]]$password1,[string[]]$apps1,[string]$upn)

    $password=$password1.split(",")
    $user=$userPrefix.split(",")
    $user
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
    
    
    if($upn)
    {
    #Adding UPN to the trusted hosts if it isn't already added.
    $upn
    $upns=Get-ADForest|select UPNSuffixes
    $upnsuffixes=$upns.UPNSuffixes
        if($upnsuffixes -notcontains $upn)
            { 
            $upn
	        $upnMsg="The UPN doesn't exist hence adding UPN:$upn"
            Get-ADForest | Set-ADForest -UPNSuffixes @{Add=$upn}
	        $upnMsg="Added $upn"
            }
            $upnMsg
        #Create user with the given UPN if the user count is equal to 1.
        if($user.count -eq 1){
        
        $arr = new-object System.Collections.arrayList
        $passwordString=$password.ToString();
        $userprincipalname = $user + "@"+$upn
        $output=New-ADUser -SamAccountName $_.SamAccountName -UserPrincipalName  $userprincipalname -Name $user -DisplayName $user -EmployeeID $employeeId -Description $apps -GivenName $user -SurName " " -Path $path -AccountPassword (ConvertTo-SecureString $passwordString -AsPlainText -force) -Enabled $True -PasswordNeverExpires $True -PassThru 
        $object = New-Object -TypeName PSObject
        $object | Add-Member -Name 'userName' -MemberType Noteproperty -Value $output.GivenName
        $arr+=$object
     }
        elseif($user.count -gt 1)
     {
        #Create multiple users with the given UPN.
        $arr = new-object System.Collections.arrayList
        for($i=0;$i -lt $user.count;$i++)
        {
        
            $passwordString=$password[$i].ToString();
            #Get-ADForest | Set-ADForest -UPNSuffixes @{add=$upn[$i]}
            $userprincipalname = $user[$i] + "@"+$upn
            $user[$i]
            $output=New-ADUser -SamAccountName $_.SamAccountName -UserPrincipalName  $userprincipalname -Name $user[$i] -DisplayName $user[$i] -GivenName $user[$i] -SurName " " -Path $path -AccountPassword (ConvertTo-SecureString $passwordString -AsPlainText -force) -Enabled $True -PasswordNeverExpires $True -PassThru 
            $object = New-Object -TypeName PSObject
            $object | Add-Member -Name 'userName' -MemberType Noteproperty -Value $output.GivenName
            $arr+=$object
 
        }
     }
    }
    else
    {
        $arr = new-object System.Collections.arrayList
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
        for($i=0;$i -lt $user.count;$i++)
            {
            $passwordString=$password[$i].ToString();
            $userprincipalname = $user[$i] + "@"+$domainName
            $output=New-ADUser -SamAccountName $_.SamAccountName -UserPrincipalName  $userprincipalname -Name $user[$i] -DisplayName $user[$i] -GivenName $user[$i] -SurName " " -Path $path -AccountPassword (ConvertTo-SecureString $passwordString -AsPlainText -force) -Enabled $True -PasswordNeverExpires $True -PassThru 
            $object = New-Object -TypeName PSObject
            $object | Add-Member -Name 'userName' -MemberType Noteproperty -Value $output.GivenName
            $arr+=$object
            }
        }
     }


$usersfinal=$arr | ConvertTo-Json
return $usersfinal
