Import-Module NTFSSecurity
Import-module ActiveDirectory

$RootFolder = 'C:\FSPOSUAI'
$x500Domain = 'OU=FSPOSUAI,DC=STDM2,DC=LOCAL'

$GroupsSharedFolders = $(Get-ADGroup -Filter * -SearchBase $x500Domain).Name

function SetAccessFolders($Domain, $RootFolder, $GroupsFolders) {

    foreach($Group in $GroupsFolders) {
    
    Clear-NTFSAccess -Path "$RootFolder\$Group" -DisableInheritance
     
        Add-NTFSAccess `
            -Path "$RootFolder\$Group" `
            -Account "STDM2\$Group", "STDM2\Teachers" `
            -AccessRights Write, Delete, ReadPermissions, Read, ReadAndExecute, Modify `
            -AccessType Allow

        Add-NTFSAccess `
            -Path "$RootFolder\$Group" `
            -Account "SYSTEM", 'STDM2\Администратор' `
            -AccessRights Full `
            -AccessType Allow

        $GroupMembers = $(Get-ADGroupMember -Identity $Group).Name

        foreach($Folder in $GroupMembers) {

            Clear-NTFSAccess -Path "$RootFolder\$Group\$Folder" -DisableInheritance

            if ($Group -eq "Teachers") {
                 Add-NTFSAccess `
                    -Path "$RootFolder\$Group\$Folder" `
                    -Account "STDM2\$Folder"`
                    -AccessRights Write, Delete, ReadPermissions, Read, ReadAndExecute, Modify `
                    -AccessType Allow

            } else {
                 Add-NTFSAccess `
                    -Path "$RootFolder\$Group\$Folder" `
                    -Account "STDM2\$Folder", "STDM2\Teachers"  `
                    -AccessRights Write, Delete, ReadPermissions, Read, ReadAndExecute, Modify `
                    -AccessType Allow
            }

            Add-NTFSAccess `
                -Path "$RootFolder\$Group\$Folder" `
                -Account "SYSTEM", 'STDM2\Администратор' `
                -AccessRights Full `
                -AccessType Allow
        }
    }
}

SetAccessFolders $x500Domain $RootFolder $GroupsSharedFolders