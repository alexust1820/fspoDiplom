Import-module ActiveDirectory

$RootFolder = 'C:\FSPOSUAI'
$x500Domain = 'OU=FSPOSUAI,DC=STDM2,DC=LOCAL'

$GroupsSharedFolders = $(Get-ADGroup -Filter * -SearchBase $x500Domain).Name

function SyncGroupsFolders($Domain, $RootFolder, $GroupsFolders) {

    if ($(Get-ChildItem -Path "$RootFolder" -directory).Name -eq $null) {
        $GFArrToAdd = $GroupsFolders
    } elseif ($GroupsFolders -eq $null) {
        $GFArrToDel = $(Get-ChildItem -Path "$RootFolder" -directory).Name
    } else {
        $CurrGroupsFolders = $(Get-ChildItem -Path "$RootFolder" -directory).Name
        $CompareGroupsFolders =  $(Compare-Object -ReferenceObject $GroupsFolders `
                                    -DifferenceObject $CurrGroupsFolders `
                                    -IncludeEqual)
        $GFArrToDel = $($CompareGroupsFolders | where SideIndicator -EQ "=>").InputObject
        $GFArrToAdd = $($CompareGroupsFolders | where SideIndicator -EQ "<=").InputObject
    }
    
    if ($GFArrToDel.count -gt 0) {
        foreach ($Group in $GFArrToDel) {
            Remove-Item -Path "$RootFolder\$Group" `
                        -Recurse `
                        -Force
        }
    }

    if ($GFArrToAdd.count -gt 0) {
        foreach ($Group in $GFArrToAdd) {   
            New-Item -Path "$RootFolder\$Group" `
                     -ItemType Directory
        }
    }
}

function SyncUsersFolders($Domain, $RootFolder, $Groups) {
    foreach ($Group in $Groups) {
        
        $GroupMembers = $(Get-ADGroupMember -Identity $Group).Name
        
        $GroupMembers += "$($Group)_public"

        if ($(Get-ChildItem -Path "$RootFolder\$Group" -directory).Name -eq $null) {
            $UFArrToAdd = $GroupMembers
        } else {
            $CurrUsersFolders = $(Get-ChildItem -Path "$RootFolder\$Group" -directory).Name
            $CompareUsersFolders =  $(Compare-Object -ReferenceObject $GroupMembers `
                                        -DifferenceObject $CurrUsersFolders `
                                        -IncludeEqual)
            $UFArrToDel = $($CompareUsersFolders | where SideIndicator -EQ "=>").InputObject
            $UFArrToAdd = $($CompareUsersFolders | where SideIndicator -EQ "<=").InputObject
        }

        
        if ($UFArrToDel.count -gt 0) {
            foreach ($Folder in $UFArrToDel) {
                Remove-Item -Path "$RootFolder\$Group\$Folder" `
                            -Recurse `
                            -Force
            }
        }

        if ($UFArrToAdd.count -gt 0) {
            foreach ($Folder in $UFArrToAdd) {
               New-Item -Path "$RootFolder\$Group\$Folder" `
                     -ItemType Directory
            }
        }
    }
}

SyncGroupsFolders $x500Domain $RootFolder $GroupsSharedFolders
SyncUsersFolders $x500Domain $RootFolder $GroupsSharedFolders