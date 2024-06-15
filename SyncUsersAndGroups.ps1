import-module ActiveDirectory

$x500Domain = 'OU=FSPOSUAI,DC=STDM2,DC=LOCAL'

$UsersDB = $(Import-Csv -Path ".\db\users.csv" -Delimiter ";" )
$GroupsDB = $(Import-Csv -Path ".\db\groups.csv" -Delimiter ";" ).Name

$ADUsersDB = $(Get-ADUser -Filter * -SearchBase $x500Domain)
$ADGroupsDB = $(Get-ADGroup -Filter * -SearchBase $x500Domain).Name

function SyncADGroups($DomainPath, $Groups, $ADGroups) {

    if ($ADGroups -eq $null) {
        $GroupsArrToAdd = $Groups
    } else {
        $CompareGroups = $(Compare-Object -ReferenceObject $Groups -DifferenceObject $ADGroups)
        $GroupsArrToAdd = $($CompareGroups | where SideIndicator -EQ "<=").InputObject
        $GroupsArrToDel = $($CompareGroups | where SideIndicator -EQ "=>").InputObject
    }

    

    if ($GroupsArrToDel.count -gt 0) {

       foreach ($Group in $GroupsArrToDel) {
            $ADUsersListOfGroup = $(Get-ADGroupMember "$Group").Name

            foreach ($User in $ADUsersListOfGroup) {
                Remove-ADUser -Identity $User -Confirm:$False
            }

            Remove-ADGroup -Identity $Group -Confirm:$False
       } 
    }
    
    if ($GroupsArrToAdd.count -gt 0) {

        foreach ($Group in $GroupsArrToAdd) {
            New-ADGroup -Name $Group `
                    -SamAccountName $Group `
                    -GroupCategory Security `
                    -GroupScope Global `
                    -DisplayName $Group `
                    -Path $DomainPath `
                    -Description "Группа для $Group"
        }
    }
}

function SyncADUsers($DomainPath, $Users, $ADUsers) {

    if ($ADUsers -eq $null) {
        $UsersArrToAdd =  $Users
    } else {
        $CompareUsers = $(Compare-Object -ReferenceObject $Users `
                                -DifferenceObject $ADUsers `
                                -Property Name `
                                -IncludeEqual `
                                -PassThru)
        $UsersArrToAdd = @($CompareUsers | where SideIndicator -EQ "<=")
        $UsersArrToDel = $($CompareUsers | where SideIndicator -EQ "=>").Name
    }

    if ($UsersArrToDel.count -gt 0) {
        foreach ($User in $UsersArrToDel) {
            Remove-ADUser -Identity $User -Confirm:$False
        }
    }

    if ($UsersArrToAdd.count -gt 0) {
        foreach ($User in $UsersArrToAdd) {
            New-ADUser -Name $User.Name `
                    -SamAccountName $User.Name `
                    -Path $DomainPath `
                    -GivenName $User.GivenName `
                    -Surname $User.Surname `
                    -Initials "$($User.GivenName[0]).$($User.Surname[0])." `
                    -AccountPassword $(ConvertTo-SecureString "P@ssw0rd" -AsPlainText -Force) `
                    -Enable $True `
                    -ChangePasswordAtLogon $False

            Add-ADGroupMember -Identity $User.Group -Members $User.Name
        }
    }
}

SyncADGroups $x500Domain $GroupsDB $ADGroupsDB
SyncADUsers $x500Domain $UsersDB $ADUsersDB