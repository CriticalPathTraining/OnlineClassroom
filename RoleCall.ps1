cls
Write-Host 


$TenantDomainName = "PBIClassroom123"
Write-Host "Classroom Domain: $TenantDomainName"
Write-Host 

$CurrentDirectory = Get-Location 
$StudentsFilePath = ("{0}\Students.csv" -f $CurrentDirectory.Path)
$Students = Import-csv -path $StudentsFilePath
foreach($Student in $Students) { 
  $StudentUPN = $Student.FirstName + "." + $Student.LastName + "@" + $TenantDomainName + ".onMicrosoft.com"
  $StudentDisplayName = $Student.FirstName + " " + $Student.LastName
  Write-Host ($StudentUPN)
  
}


Write-Host 