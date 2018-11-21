[CmdletBinding()] 

Param (

[parameter(Mandatory=$true,HelpMessage="Enter instance name")] 
[string]$InstName,

[parameter(Mandatory=$true,HelpMessage="Enter password for DMK")] 
[securestring]$DMKpassw,

[parameter(Mandatory=$true,HelpMessage="Enter a drive where you want to store your certificate [ex. C]")] 
[string]$DriveLet,

[parameter(Mandatory=$true,HelpMessage="Enter password for certificate")] 
[securestring]$Certpassw
)

$ErrorActionPreference='inquire'

$answer = Read-Host "Do you want to create a new user? [y/n]"
$answer = $answer[0].ToString().ToLower()

#Creating new Users while the answer is 'y'
try {
while ($answer -eq 'y')  {
    $LoginName = Read-Host "Enter login name: [ex. ADATUM\dev1]"
    $DBUsed = Read-Host "Enter default DB:"

    $UserCreation = @"
USE [master]
GO
CREATE LOGIN [$LoginName] FROM WINDOWS WITH DEFAULT_DATABASE=[$DBUsed]
GO
USE [$DBUsed]
GO
CREATE USER [$LoginName] FOR LOGIN [$LoginName]
GO 
"@
}
catch [System.Exception] {"Error occured!"}

    #Adding new role
    $DBRole1 = Read-Host "Enter the role you want to give to the user [ex. db_datawriter]"
    $AltQuery=@"
USE [$DBUsed]
GO
ALTER ROLE [$DBRole1] ADD MEMBER [$LoginName]
GO 

"@

    $UserCreation+=$AltQuery

        #Addind more roles
        $answer1= Read-Host "Do you want to add another role? [y/n]"
        $answer1 = $answer1[0].ToString().ToLower()

        while ($answer1 -eq 'y')
        {
        $DBRole1 = Read-Host "Enter the role you want to give to the user [ex. db_datawriter]"

        $AltQuery=@"    
USE [$DBUsed]     GO     ALTER ROLE [$DBRole1] ADD MEMBER [$LoginName]    GO 

"@    

        $UserCreation+=$AltQuery

        $answer1= Read-Host "Do you want to add another role? [y/n]"
        $answer1 = $answer1[0].ToString().ToLower()
        }
        

            #Removing roles
            $answer2= Read-Host "Do you want to remove some role? [y/n]"
            $answer2 = $answer2[0].ToString().ToLower() 
            while ($answer2 -eq 'y')
            {
            $DBRole1 = Read-Host "Enter the role you want to give to the user [ex. db_owner]"

            $AltQuery=@"    
USE [$DBUsed]     GO     ALTER ROLE [$DBRole1] DROP MEMBER []    GO 

"@    

            $UserCreation+=$AltQuery

            $answer2= Read-Host "Do you want to add another role? [y/n]"
            $answer2 = $answer2[0].ToString().ToLower()
            }
                       

Try {
Invoke-Sqlcmd -ServerInstance $InstName -Query $UserCreation
}
catch [System.Exception] {"Error occured!"}
}

#DB Encryption

$Encryption = @"
USE master;
create master key encryption by password = '$DMKPassw';

create certificate Security_Certificate with subject = 'DEK_Certificate';

backup certificate Security_Certificate to file = '${$DriveLet}:\security_Certificate.cer'
with private key
(file = '${$DriveLet}:\security_Certificate.key',
encryption by password = '$Certpassw');


Use $DBUsed ;
Create database encryption key
with algorithm = AES_128
encryption by server certificate Security_Certificate;

ALTER database $DBUsed
set encryption on

"@

try {
Invoke-Sqlcmd -ServerInstance $InstName -Query $Encryption
}
catch {
    [System.Exception] 
    "Error has occured!"
}
    