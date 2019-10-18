
#Get all running services
#Get-Service | where {$_.Status -eq 'running'}

## disable features ( IIS / FAX/ FTP / TELNET
foreach($item in Get-WindowsOptionalFeature -Online | where { ($_.FeatureName -like "*ftp*")  -or  ($_.FeatureName -like "*smb*") -or ($_.FeatureName  -like "*iis*")  -or ($_.FeatureName  -like "*telnet*") -or ($_.FeatureName -like "*fax*")}) {

    #$name=$item.FeatureName
    Disable-WindowsOptionalFeature -Online -NoRestart -FeatureName $item.FeatureName
     
}