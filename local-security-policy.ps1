Function Parse-SecPol($CfgFile){ 
    secedit /export /cfg "$CfgFile" | out-null
    $obj = New-Object psobject
    $index = 0
    $contents = Get-Content $CfgFile -raw
    [regex]::Matches($contents,"(?<=\[)(.*)(?=\])") | %{
        $title = $_
        [regex]::Matches($contents,"(?<=\]).*?((?=\[)|(\Z))", [System.Text.RegularExpressions.RegexOptions]::Singleline)[$index] | %{
            $section = new-object psobject
            $_.value -split "\r\n" | ?{$_.length -gt 0} | %{
                $value = [regex]::Match($_,"(?<=\=).*").value
                $name = [regex]::Match($_,".*(?=\=)").value
                $section | add-member -MemberType NoteProperty -Name $name.tostring().trim() -Value $value.tostring().trim() -ErrorAction SilentlyContinue | out-null
            }
            $obj | Add-Member -MemberType NoteProperty -Name $title -Value $section
        }
        $index += 1
    }
    return $obj
}

Function Set-SecPol($Object, $CfgFile){
   $SecPool.psobject.Properties.GetEnumerator() | %{
        "[$($_.Name)]"
        $_.Value | %{
            $_.psobject.Properties.GetEnumerator() | %{
                "$($_.Name)=$($_.Value)"
            }
        }
    } | out-file $CfgFile -ErrorAction Stop
    secedit /configure /db c:\windows\security\local.sdb /cfg "$CfgFile" /areas SECURITYPOLICY
}


$SecPool = Parse-SecPol -CfgFile ./Test.cgf

## Update Password Policy
$SecPool.'System Access'.PasswordComplexity = 1
$SecPool.'System Access'.MinimumPasswordLength = 14
$SecPool.'System Access'.MaximumPasswordAge = 60
$SecPool.'System Access'.MinimumPasswordAge = 5
$SecPool.'System Access'.PasswordHistorySize = 5

## Account Account Policies
$SecPool.'System Access'.LockoutBadCount = 5
$SecPool.'System Access'.LockoutDuration = 30
$SecPool.'System Access'.ResetLockoutCount = 5


## Enable AUdit Events -Success and Failure
$SecPool.'Event Audit'.AuditSystemEvents=3
$SecPool.'Event Audit'.AuditLogonEvents=3
$SecPool.'Event Audit'.AuditPrivilegeUse=3
$SecPool.'Event Audit'.AuditPolicyChange=3
$SecPool.'Event Audit'.AuditAccountLogon=3
$SecPool.'Event Audit'.AuditAccountManage=3


Set-SecPol -Object $SecPool -CfgFile ./Test.cfg