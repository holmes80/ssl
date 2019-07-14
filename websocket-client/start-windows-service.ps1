# Script for making websocket-client.ps as widowos service 
## Step to creating Windows service
# 1. Downlod nssm in C:\Program Files\nssm and add path here
# 2. Add websocket_client_new.ps1 location in this file
# 3. Run this script manually

$nssm = (Get-Command "C:\Program Files\nssm\win64\nssm.exe").Source
$serviceName = 'WS-client'
$powershell = (Get-Command powershell).Source
$scriptPath = 'C:/websocket_client_new.ps1 ws://104.214.101.73:8001/clientdata'
$arguments = '-ExecutionPolicy Bypass -NoProfile -File "{0}"' -f $scriptPath
& $nssm install $serviceName $powershell $arguments
& $nssm status $serviceName
Start-Service $serviceName
Get-Service $serviceName