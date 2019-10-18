## Read a file of users and reset all passwords

foreach($name in Get-Content .\users.txt) {

    $Password = ConvertTo-SecureString -String "P@sSwOrd" -AsPlainText -Force
    $UserAccount = Get-LocalUser -Name $name
    $UserAccount | Set-LocalUser -Password $Password

    ## List all the users
    $UserAccount

}

## Disable user that is not in the file
