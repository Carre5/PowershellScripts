#Help: https://gallery.technet.microsoft.com/scriptcenter/Export-all-AD-groups-and-3ae6fb42

param(
    [string]$serverName,
    [string]$OUName,
    [string]$OutputPath = "C:\Users\"+$env:UserName+"\Desktop"
)

if(-not($serverName) -and -not($OUName)) {
    Throw "You must supply a value for at least 2 parameters to run the script ( -serverName, -OUName )"
}
else {
    # Get all groups from specified OU
    $ADGroups = Get-ADGroup -Filter * -server $serverName -SearchBase $OUName

    # Path to create csv file
    $DateTime = Get-Date -f "yyyy-MM-dd"
    $CSVFile = $OutputPath+"\"+"AD_Groups_$DateTime.csv"
    $CSVOutput = @()

    # Variables for progressBar
    $i=0
    $dl=$ADGroups.count 

    foreach($ADGroup in $ADGroups)
    { 
	    $i++
        $status = "{0:N0}" -f ($i /$dl * 100)

	    Write-Progress -Activity "Obtaining AD Groups" -status "Searching domain groups and its members... $status%" -PercentComplete ($i / $dl *100)
	    $MembersArr = Get-ADGroup -Server $serverName -filter {Name -eq $ADGroup.Name} | Get-ADGroupMember -Server $serverName | Select-Object Name

	    $Members=""

        if($MembersArr){
            foreach($Member in $MembersArr)
            {
                if($Member.objectClass -eq "user"){
                    $UserObj = Get-ADUser -Server $serverName -filter {DistinguishedName -eq $Member.distinguishedName}
                    if($UserObj.Enabled -eq $False){
                        continue
                    }
                }
                # Breaking the line in csv standard opens posibility to fill cell vertically
                $Members = $Members + "`r`n" + $Member.Name
            }

            if($Members){
                $Members = $Members.Substring(2,($Members.Length) -2)
            }
        }

        # HashTab for CSV
        $HashTab = $NULL
        $HashTab = [ordered]@{
            "Grupa"=$ADGroup.Name
            "Czlonkowie"=$Members
        }

        $CSVOutput += New-Object PSObject -Property $HashTab
    }

    $CSVOutput | Sort-Object Name | Export-CSV $CSVFile -Encoding UTF8 -NoTypeInformation

    Write-Output "CSV file saved in: $CSVFile"
}