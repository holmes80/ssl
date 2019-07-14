# Copywrite: Dongjin Suh (dongjin.suha@stratussilverlining.com
param (
    [Parameter(Mandatory=$true)][string]$server
)


###### Data for accumulative runing time

# Persistent Data Structure for Output
$userDetails = [ordered]@{}          ### For APPLICATION data
$userOccurrences = [ordered]@{}      ### For APPLICATION data

$userDetails_logon = [ordered]@{}    #### for LOGON data
$userOccurrences_logon = [ordered]@{} ### for LOGON data

$global:sleepSeconds = 10
$resetMinTime = Get-Date '00:00'  # The Min reset-time for reset accmulated run time
$resetMaxTime = Get-Date '00:01'  # The Max reset-time for reset accmulated run time  
$global:flushed = 0              # Check if current scan is first time ever or first time for this flush iteration     
$global:flushed_logon = 0              # Check if current scan is first time ever or first time for this flush iteration     
$global:foundSameUser = $false  # check if any disconnected user locates
$global:foundSameUser_hash = $false  # check if any disconnected user in Adding Static value in hashtable 
$global:newSesh = 0
$global:prev_AppTime =[System.Diagnostics.Stopwatch]::new()
$global:prev_LogonTime= [System.Diagnostics.Stopwatch]::new()

#$global:Time = [System.Diagnostics.Stopwatch]::StartNew()
###########################################3

##########   Function for query user : list all users information on AppServer 
Function QueryUser{
   $user_status_List = New-Object System.Collections.ArrayList

   $userdata= (((quser) -replace '^>', '') -replace '\s{2,}', ',' -replace '\.', '').Trim() | ForEach-Object {
   if ($_.Split(',').Count -eq 5) {        
       Write-Output ($_ -replace '(^[^,]+)', '$1,')
   } else {       
       Write-Output $_
    }
   }
   $arr = $userdata -split ','
   #########  Logon User data : format 
    ## User Name; SessionName ; SessionID, STATE; IdleTime; LogonTime; LogoutTIme
    # @{UserName=mn_admin; sessionName=; sessionID=2; STATE=Disc; IdleTime=1:27; LogonTime=4/16/2019 6:14 AM; LogoutTime=}
    # @{UserName=dongjin; sessionName=rdp-tcp#37; sessionID=3; STATE=Active; IdleTime=.; LogonTime=4/18/2019 2:21 PM; LogoutTime=}

    for($i=0; $i -lt ($arr.Count/6 -1); $i++){

    $user_status = New-Object -TypeName psobject
    $user_status | Add-Member NoteProperty -Name UserName -Value $arr[6+$i*6]
    $user_status | Add-Member NoteProperty -Name sessionName -Value $arr[7+$i*6]
    $user_status | Add-Member NoteProperty -Name sessionID -Value $arr[8+$i*6]
    $user_status | Add-Member NoteProperty -Name STATE -Value $arr[9+$i*6]
    $user_status | Add-Member NoteProperty -Name IdleTime -Value $arr[10+$i*6]
    $user_status | Add-Member NoteProperty -Name LogonTime -Value $arr[11+$i*6]
    $logon_time = $arr[11+$i*6]
    $run_time =[math]::round( ((Get-date) - [datetime]$logon_time ).totalhours, 2)    
    $user_status | Add-Member NoteProperty -Name RunTime -Value $run_time
    $user_status_List.Add($user_status)  > $null
    }
  
    return $user_status_List

}
##############################################################
     ######## To return Client's Logon Data  ########
##############################################################
Function GetClientLogonData{
    ################ CHeck USER STATUS of App server ###################################
        ## Array of Users for checking USER status on App server  
        $query_user_status_List = New-Object System.Collections.ArrayList
        $query_user_status_List = QueryUser
    ####################################################################################
        $global:LogonTime = [System.Diagnostics.Stopwatch]::StartNew() 
        ###################################################################
           ####### Accumulated Runtime for LOGON User  ###############
        ########## Accumulated RESET by given time ###########################
       $now_time = Get-Date
        if ($resetMinTime.TimeOfDay -le $now_time.TimeOfDay -And $resetMaxTime.TimeOfDay -ge $now_time.TimeOfDay){
            $global:flushed_logon = 1
        } else {
            $global:flushed_logon = 0
        }
    
        if ($global:flushed_logon -eq 1){
            $userDetails_logon.Clear()
            $userOccurrences_logon.Clear()
            Write-Host("Resetting Accmulated Time for LOGON DATA")
            #sleep ($resetMaxTime - $resetMinTime).TotalSeconds
        }
    
        ################################################################
           ###################################Accumulated Run Time  ###################################################
        
        $query_user_status_List = New-Object System.Collections.ArrayList
        $query_user_status_List = QueryUser    
      
    
        ###################################################################
      #  Write-Host $query_user_status_List
        $sub_str="Logon"
        foreach( $query_user_status in $query_user_status_List){    
            $sub_str +=";"
            $sub_str += $query_user_status
            $sub_str +=";"
            # FOR AccRt
            #$sub_str +=$userDetails_logon[$query_user_status.UserName]

            # For oneElapsedTime
            try{
                $totalRunTime = ([math]::round(([decimal]$global:prev_LogonTime+$global:prev_AppTime) /3600 , 4))    
            }
            catch{
                $totalRunTime = ([math]::round((2.5 *$global:sleepSeconds ) /3600 , 4))
            }
            $sub_str +=  $totalRunTime          
    
        } 
        
        $global:cur_logontime = $global:LogonTime.Elapsed
      # write-host $query_user_status_List
        return $sub_str
    }
    

##############################################################
    ######## To return Client's application Data  #######
##############################################################
Function GetClientApplicationData{

# Authored by Dongjin Suh for Stratus Silver Lining (Internal Use Only)

$cpu = New-Object -TypeName psobject
$cpu | Add-Member NoteProperty -Name TotalCPU -Value 0
$cpu | Add-Member NoteProperty -Name PreviousCPU -Value 0
$cpu | Add-Member NoteProperty -Name CurrentCPU -Value 0
$cpu | Add-Member NoteProperty -Name NumCores -Value (Get-WMIObject Win32_ComputerSystem).NumberOfLogicalProcessors

# Array of Users
$usersList = New-Object System.Collections.ArrayList

################ CHeck USER STATUS of App server ###################################
    ## Array of Users for checking USER status on App server  
    $query_user_status_List = QueryUser
####################################################################################
     $global:AppTime = [System.Diagnostics.Stopwatch]::StartNew() 
  ########## Accumulated RESET by given time ###########################
   $now_time = Get-Date
    if ($resetMinTime.TimeOfDay -le $now_time.TimeOfDay -And $resetMaxTime.TimeOfDay -ge $now_time.TimeOfDay){
        $global:flushed = 1
    } else {
        $global:flushed = 0
    }

    if ($global:flushed -eq 1){
      #  $userDetails.Clear()
      #  $userOccurrences.Clear()
        Write-Host("Resetting Accmulated Time for USAGE DATA")
       # sleep ($resetMaxTime - $resetMinTime).TotalSeconds
    }
    
               #### Procedure for CPU stat read ###########
    # Handle CPU Related Info
    $cpu.PreviousCPU = $cpu.TotalCPU
    $cpu.TotalCPU = 0

    ForEach ($user in $usersList) {
        $user.PreviousCPU = $user.TotalCPU
        $user.TotalCPU = 0
    }
      

    # Get list of processes
    $IdleTime = ((Get-Counter '\Process(idle)\% Processor Time' -SampleInterval 1 | Foreach-Object {$_.CounterSamples[0].CookedValue}) / $cpu.NumCores)
    $RunningTime = 100 - $IdleTime
    $processList = $null
    $processList = Get-Process -IncludeUserName | select Id, Username, ProcessName, CPU, starttime -ErrorAction SilentlyContinue
      
    
    ForEach ($process in $processList) {    
     
        $found = 0
        $cpu.TotalCPU += $process.CPU       
       
        if (($process.Username -eq $null) -or ([string]$process.Username -like "*NT AUTHORITY*") -or ([string]$process.Username -like "*Window Manager*") -or ([string]$process.Username -like "*Font Driver Host*")) {
            $found = 1
            continue
        }          
       
        #################################################################################################
        For ($i=0; $i -le $usersList.Count; $i++){ 
            
            if ($process.Id -eq 0) {
                break
            }
            if ($usersList[$i].Username -eq $process.Username){
                $found = 1
                $usersList[$i].TotalCPU += $process.CPU
                $usersList[$i].processes.Add($process) > $null
                break
            }
        }
        if ($found -eq 0) {            
            $user = New-Object -TypeName psobject       
            $user | Add-Member NoteProperty -Name Username -Value $process.Username
            $user | Add-Member NoteProperty -Name TotalCPU -Value $process.CPU
            $user | Add-Member NoteProperty -Name PreviousCPU -Value 0
            $user | Add-Member NoteProperty -Name CurrentCPU -Value 0         
        #    $user | Add-Member NoteProperty -Name CurrentTime -Value Get-Date        
            $processes = New-Object System.Collections.ArrayList
            $processes.add($process) > $null
            $user | Add-Member NoteProperty -Name Processes -Value $processes            
            $usersList.Add($user) > $null
        }
    }  

    $cpu.CurrentCPU = $cpu.TotalCPU - $Cpu.PreviousCPU

    ######################################################
    #Clear-Host

    $tableName = "CPU Load Statistics"
    $table = New-Object system.Data.DataTable $tableName
    $col1 = New-Object system.Data.DataColumn User,([string])
    $col2 = New-Object system.Data.DataColumn CPU,([string])
    $table.columns.add($col1)
    $table.columns.add($col2)  
    $outItems = New-Object System.Collections.Generic.List[System.Object]

    $sub_str=""
     $sub_str +="Usage;"
    ForEach ($user in $usersList) {
    
    #################################################
        if ([string]$user.Username -like "*NT AUTHORITY*" -or [string]$User.Username -like "*Window Manager*" -or [string]$User.Username -like "*Font Driver Host*") {       
            continue
        }
      
    #    Write-Host $query_user_status_List +";"

        ForEach( $user_status in $query_user_status_List){   
        $split_name = $user.Username -split '\\'
     #  Write-host($user_status.UserName+";"+ $split_name[1]+"in the loop1")  
    ##  This user is not Active; meaning "Disconnected or idle"
            if( ($user_status.UserName -like $split_name[1]) -and ($user_status.STATE -ne "Active")){
      #           Write-host($user_status.UserName+";"+ $split_name[1]+"in the loop2")  
                $global:foundSameUser = $true                            
            }   
            elseif( ($user_status.UserName -like $split_name[1]) -and ($user_status.STATE -eq "Active")){
      #           Write-host($user_status.UserName+";"+ $split_name[1]+"in the loop2")  
                $global:foundSameUser = $false
                break              # break means stopping loop and this user data has to be seen.
            }   
            #Write-host("Hi"+  $user_status.UserName)                                                    
        }
        # This "if" is TRUE only user is not Active for entire user loop
        if( $global:foundSameUser -eq $true) {
       #     Write-host("loop333333333")
            $global:foundSameUser = $false
            continue  #Continue means "skipping user data to be shown"
        }
        #    if([string]$user.Username -like "*mn_admin*"){
        #         continue
        #   }
    #       ######### Check for user_Status if the user name matches and connected #########################
        # Calculate CPU
        $user.CurrentCPU = $user.TotalCPU - $user.PreviousCPU
        $usage = ([math]::Round(($RunningTime * ($user.CurrentCPU/$cpu.CurrentCPU)), 2))
        $row = $table.NewRow()
        $row.User = $user.Username
        $row.CPU = [string]$usage 
        $table.Rows.Add($row)                
       
        $cnt=0;
       
        ForEach( $process in $user.Processes)
        {           
            ############### Test-Start
            $cnt += 1
            ########################End 

            $str =  $process
            $sub_str += $row.CPU
            $sub_str +=  ";"
            $sub_str += $str               
            $sub_str +=  ";"
         #   $sub_str += Get-Date -UFormat "%D %H:%M:%S;"

            $cur_time = Get-Date
            $start_time =($process.StartTime)
            $run_time = [math]::Round((New-TimeSpan $start_time $cur_time).TotalHours, 2)

            ####Calculate running time of each app        
         
            $sub_str +=$run_time
            $sub_str += "; "
         
            ### Changed running code ###
            #Write-Host "user is $user, process is $process"
           # $accRt = $userDetails[$process.UserName].item($process.ProcessName)
           try{
                $totalRunTime = ([math]::round(([decimal]$global:prev_LogonTime+$global:prev_AppTime) /3600 , 4))    
            }
            catch{
                $totalRunTime = ([math]::round((2.5 *$global:sleepSeconds ) /3600 , 4))
            }
            $sub_str +=  $totalRunTime 
            $sub_str += ";"               
                
     #       $sub_str += "`n"      
            
        }       

    }
    $global:cur_apptime = $global:AppTime.Elapsed
    #Write-host ("current AppTime lap is" + $cur_apptime )
    return  $sub_str
}

Try{  

    Do{    
       
        $beChangeTurn = $true
        $WS = New-Object System.Net.WebSockets.ClientWebSocket                                                
        $CT = New-Object System.Threading.CancellationToken                                                   

        $Conn = $WS.ConnectAsync($server, $CT)                                                  
        While (!$Conn.IsCompleted) { Start-Sleep -Milliseconds 100 }

        Write-Host "`nConnected to" $server -ForegroundColor Green

        $Size = 1024
        $Array = [byte[]] @(,0) * $Size
        $Recv = New-Object System.ArraySegment[byte] -ArgumentList @(,$Array)

        While ($WS.State -eq 'Open') {
              $global:Time = [System.Diagnostics.Stopwatch]::StartNew()     
            $rev_str=""
            $RTM = ""
     ################ Get client Data ################
             sleep $global:sleepSeconds
            if($beChangeTurn -eq $true){
             $RTM = GetClientApplicationData            
             $beChangeTurn = $false
           }else{
             $RTM = GetClientLogonData
             $beChangeTurn = $true            
            }
     ################################################### 

           # Write-Host "`nData to send Server:$RTM" -ForegroundColor Yellow            
            $enc = [system.Text.Encoding]::UTF8
       
            $Reply = $enc.GetBytes($RTM) 
            $Conn = $WS.SendAsync($Reply, [System.Net.WebSockets.WebSocketMessageType]::Text, [System.Boolean]::TrueString, $CT)                        
            Do {
                $Conn = $WS.ReceiveAsync($Recv, $CT)
                While (!$Conn.IsCompleted) { Start-Sleep -Milliseconds 100 }

                $Recv.Array[0..($Conn.Result.Count - 1)]  | ForEach {  $rev_str += [char]$_   }
          #      Write-Host ("Recevecing data from Server:"+$rev_str)                     
            } Until ($Conn.Result.Count -lt $Size)              
             
        $global:CurrentTime = $global:Time.Elapsed           
          
        ######  Save current APPTime and LogOnTime ############
        if (!$beChangeTurn){
                   Write-Host "USAGE Data "
                  $global:prev_AppTime = [math]::Round( $global:CurrentTime.TotalSeconds,4)
              #    Write-host ("current AppTime lap is" +$global:prev_AppTime)
          } else {
            Write-Host "LOGON data "
            $global:prev_LogonTime = [math]::Round( $global:CurrentTime.TotalSeconds,4)
            #Write-host ("current LogonTime lap is" +$global:prev_LogonTime)            
          }
       
        ######  Save current APPTime and LogOnTime ############
        #$global:prev_AppTime = [math]::Round(($global:cur_apptime).TotalSeconds+5+$global:sleepSeconds ,4)
        #$global:prev_LogonTime = [math]::Round(($global:cur_logontime).TotalSeconds+3+$global:sleepSeconds,4)

   #     Write-host ("current AppTime lap is" +$global:prev_AppTime)
   #     Write-host ("current LogonTime lap is" +$global:prev_LogonTime)

         $global:Time.Reset()
        }
    } Until (!$Conn)  #Do until connection is not existing


} Finally{

    If ($WS) { 
        Write-Host "`n`nClosing websocket`n" -ForegroundColor Red
        $WS.Dispose()
    }

}
