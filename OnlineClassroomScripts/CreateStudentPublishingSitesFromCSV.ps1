Clear-Host 


$classroomDomainName = "CptLiberty1"
$globalAdminAccountName = "Instructor"
$globalAdminPassword = "pass@word1"

$classroomDomain = $classroomDomainName + ".onMicrosoft.com"
$classroomSharePointRootSite = "https://" + $classroomDomainName + ".sharepoint.com"
$classroomSharePointTenantSite = "https://" + $classroomDomainName + "-admin.sharepoint.com"

$globalAdminAccount = $globalAdminAccountName + "@" + $classroomDomain 
$globalAdminPassword = "pass@word1"
$globalAdminSecurePassword = ConvertTo-SecureString -String $globalAdminPassword -AsPlainText -Force

function Create-Student-Sites($firstName, $lastName){

    $firstNameClean = $firstName -replace " ", ""
    $firstNameClean = $firstNameClean -replace "'", ""
 
    $lastNameClean = $lastName -replace " ", ""
    $lastNameClean = $lastNameClean -replace "'", ""


    $studentUPN = $firstNameClean + "." + $lastNameClean + "@" + $classroomDomain    
    $instructorUPN  = $globalAdminAccount
     
    $studentPublishingSiteUrl =  $classroomSharePointRootSite + "/sites/PublishingSite_"+$firstNameClean+$lastNameClean
    Write-Host "Creating publishing site at $studentPublishingSiteUrl"
    $silent = New-SPOSite -Url $studentPublishingSiteUrl -Owner $studentUPN -StorageQuota 1000 -Title "Wingtip Toys" -Template "BLANKINTERNETCONTAINER#0" -NoWait
    Write-Host " - site creation request submitted"

     # write user info for student to log file
    "Student: $firstName + "." + $lastName" | Out-File $LogFilePath -Append
    "Publishing site: $studentPublishingSiteUrl" | Out-File $LogFilePath -Append
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


$StudentsFilePath = ("{0}\LibertyStudents.csv" -f $CurrentDirectory.Path)
$Students = Import-csv -path $StudentsFilePath

foreach($Student in $Students) { 
    Create-Student-Sites $Student.FirstName $Student.LastName 
}