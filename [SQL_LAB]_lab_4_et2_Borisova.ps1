[PSCustomObject]@{
    'Function' = "dev"
    'Username' = "Vasya_Pupkin"
    'Password' = 'Pa$$w0rd'
}, 
[PSCustomObject]@{
    'Function' = "test"
    'Username' = "Petya_Lunin"
    'Password' = 'Pa$$w0rd'
}, 
[PSCustomObject]@{
    'Function' = "service app"
    'Username' = "SomeSvc"
    'Password' = 'Pa$$w0rd'
},
[PSCustomObject]@{
    'Function' = "service user"
    'Username' = "Lena_Ivanova"
    'Password' = 'Pa$$w0rd'
},
[PSCustomObject]@{
    'Function' = "backup user"
    'Username' = "Ivan_Ivanov"
    'Password' = 'Pa$$w0rd'
} | Export-Csv C:\new.csv 

$Username = (Import-Csv C:\new.csv | where-object {$_.function -eq 'dev'}).Username
