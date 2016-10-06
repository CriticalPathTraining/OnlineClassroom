Clear-Host 

# update the next three lines with values from your Office 365 tenant
$classroomDomainName = "CptClassroom0812"
$globalAdminAccountName = "Instructor"
$globalAdminPassword = "pass@word1"

$classroomDomain = $classroomDomainName + ".onMicrosoft.com"
$classroomSharePointRootSite = "https://" + $classroomDomainName + ".sharepoint.com"
$classroomSharePointTenantSite = "https://" + $classroomDomainName + "-admin.sharepoint.com"

$globalAdminAccount = $globalAdminAccountName + "@" + $classroomDomain 
$globalAdminSecurePassword = ConvertTo-SecureString -String $globalAdminPassword -AsPlainText -Force

function Create-Student-Sites($firstName, $lastName){

    $firstNameClean = $firstName -replace " ", ""
    $firstNameClean = $firstNameClean -replace "'", ""
 
    $lastNameClean = $lastName -replace " ", ""
    $lastNameClean = $lastNameClean -replace "'", ""

    $studentUPN = $firstNameClean + "." + $lastNameClean + "@" + $classroomDomain    
     
    $studentTeamSiteUrl =  $classroomSharePointRootSite + "/sites/TeamSite_"+$firstNameClean+$lastNameClean
    Write-Host "Creating team site at $studentTeamSiteUrl"
    $silent = New-SPOSite -Url $studentTeamSiteUrl -Owner $studentUPN -StorageQuota 1000 -Title "Team Site" -Template "STS#0" -NoWait
    Write-Host " - site created"

    $studentSearchSiteUrl =  $classroomSharePointRootSite + "/sites/SearchCenter_"+$firstNameClean+$lastNameClean
    Write-Host "Creating search center site at $studentSearchSiteUrl"    
    $silent = New-SPOSite -Url $studentSearchSiteUrl -Owner $studentUPN -StorageQuota 1000 -Title "Search" -Template "SRCHCEN#0" -NoWait
    Write-Host " - site created"

     # write user info for student to log file
    "Student: $firstName + "." + $lastName" | Out-File $LogFilePath -Append
    "Team site: $studentTeamSiteUrl" | Out-File $LogFilePath -Append
    "Search site: $studentSearchSiteUrl" | Out-File $LogFilePath -Append
    "" | Out-File $LogFilePath -Append
    "" | Out-File $LogFilePath -Append

	
}


# create new log file 
$CurrentDirectory = Get-Location 
$LogFilePath = ("{0}\StudentSiteLog.txt" -f $CurrentDirectory.Path)
"Log of created sharepoint sites" | Out-File $LogFilePath
"" | Out-File $LogFilePath -Append


$credential = New-Object -TypeName System.Management.Automation.PSCredential `
                         -ArgumentList $globalAdminAccount, $globalAdminSecurePassword

Connect-SPOService -Url $classroomSharePointTenantSite -credential $credential


$StudentsFilePath = ("{0}\Students.csv" -f $CurrentDirectory.Path)
$Students = Import-csv -path $StudentsFilePath

foreach($Student in $Students) { 
    Create-Student-Sites $Student.FirstName $Student.LastName 
}
