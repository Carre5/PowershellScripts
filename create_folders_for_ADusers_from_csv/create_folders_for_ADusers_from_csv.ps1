#https://4sysops.com/archives/create-a-new-folder-and-set-permissions-with-powershell

param(
    [string]$Location,
    [string]$UsersCsvFilePath,
    [string]$EditorsCsvFilePath
    )

if(-not($Location) -and -not($UsersCsvFilePath) -and -not($EditorsCsvFilePath)) {
    Throw "You must supply a value for every parameter to run the script ( -Location, - UsersCsvFilePath, -EditorsCsvFilePath )"
}
else {
    #import array of users with only ReadAndExecute permission
    $users = (Import-Csv -Path $UsersCsvFilePath).Name

    ForEach ($user in $users) {
        
        #get domainUser's login
        $samaccountname = (Get-ADUser -Filter {name -eq $user } | select sAMAccountName).sAMAccountName

        New-Item -Name $samaccountname -type directory -Path $Location

        $userName = "adds\$samaccountname"
        $folderName = $Location+"\"+$samaccountname

        #disable inheritance on created folder
        icacls $folderName /inheritance:d

        #region UsersRights
            $readOnly = [System.Security.AccessControl.FileSystemRights]"ReadAndExecute"
            $inheritanceFlag = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit"
            $propagation = [System.Security.AccessControl.PropagationFlags]::None
            $type = [System.Security.AccessControl.AccessControlType]::Allow

            $accessControlEntry = New-Object System.Security.AccessControl.FileSystemAccessRule @($userName,$readOnly,$inheritanceFlag,$propagation,$type)
            $objAcl = Get-Acl -Path $folderName
            $objAcl.AddAccessRule($accessControlEntry)
            Set-Acl -Path $folderName -AclObject $objAcl
        #endregion 

        #import array of users with FullControl permission
        $cert_editors = (Import-Csv -Path $EditorsCsvFilePath).Name

        #forEach user i'm also adding 
        ForEach($editor in $cert_editors) {
        
            $samaccountname = (Get-ADUser -Filter {name -eq $editor } | select sAMAccountName).sAMAccountName
            $adEditor = "adds\$samaccountname"

            #region EditorsRights
                $fullControl = [System.Security.AccessControl.FileSystemRights]"FullControl"
                $inheritanceFlag = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit"
                $propagation = [System.Security.AccessControl.PropagationFlags]::None
                $type = [System.Security.AccessControl.AccessControlType]::Allow

                $accessControlEntry = New-Object System.Security.AccessControl.FileSystemAccessRule @($adEditor,$fullControl,$inheritanceFlag,$propagation,$type)
                $objAcl = Get-Acl -Path $folderName
                $objAcl.AddAccessRule($accessControlEntry)
                Set-Acl -Path $folderName -AclObject $objAcl
            #endregion
        }
    }
}