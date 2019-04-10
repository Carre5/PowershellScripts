param(
    [string]$server = "adds.ou.net",
    [string]$usersPath = "D:\Projekty\PowershellScripts\create_ADusers_from_csv\adusers.csv",
    [string]$mailServer = "ou.net"
)

if(!$server -and !$usersPath) {
    Write-Output "You have to specify at least the -server and -usersPath parameters!"
}
else {
    $users = Import-Csv -Path $usersPath -Delimiter ";"

    ForEach($user in $users) {

        #someone can have a two surnames and this is handler
        $standardSurname = $user.Surname.ToLower().Split("-")
         
        $login = $user.Name.ToLower()+"."+$standardSurname[$standardSurname.Length-1]
        
        #region cut Polish chars
            $login = $login `
                -replace "ą","a"`
                -replace "ę","e"`
                -replace "ł","l"`
                -replace "ń","n"`
                -replace "ó","o"`
                -replace "ó","o"`
                -replace "ś","s"`
                -replace "ź","z"`
                -replace "ż","z"`
        #endregion

        $emailAddress = $login+"@"+$mailServer

        Write-Output $user
        Write-Output $login
        Write-Output $emailAddress
        Write-Output ""
    }
}