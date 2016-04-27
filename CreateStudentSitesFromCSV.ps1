Clear-Host 

$classroomDomainName = "CptClassroom1234"
$globalAdminAccountName = "Instructor"
$globalAdminPassword = "pass@word1"

$classroomDomain = $classroomDomainName + ".onMicrosoft.com"
$classroomSharePointRootSite = "https://" + $classroomDomainName + ".sharepoint.com"
$classroomSharePointTenantSite = "https://" + $classroomDomainName + "-admin.sharepoint.com"

$globalAdminAccount = $globalAdminAccountName + "@" + $classroomDomain 
$globalAdminPassword = "pass@word1"
$globalAdminSecurePassword = ConvertTo-SecureString -String $globalAdminPassword -AsPlainText -Force

function Create-Student-Sites($firstName, $lastName){

    $studentUPN = $firstName + "." + $lastName + "@" + $classroomDomain    
    $instructorUPN  = $globalAdminAccount
     
    $studentTeamSiteUrl =  $classroomSharePointRootSite + "/sites/TeamSite_"+$firstName+$lastName  
    Write-Host "Creating team site at $studentTeamSiteUrl"
    $silent = New-SPOSite -Url $studentTeamSiteUrl -Owner $instructorUPN -StorageQuota 1000 -Title "Team Site" -Template "STS#0" 
    Write-Host " - site created"

    Write-Host " - configuring permissions for student to access site as site owner"
    $site = Get-SPOSite $studentTeamSiteUrl
    $ownerGroup = Get-SPOSiteGroup -site $studentTeamSiteUrl | where {$_.title -like "*Owners"}
	$ownerGroupTitle = $ownerGroup.title
	$silent = Add-SPOUser -Site $studentTeamSiteUrl -LoginName $studentUPN -Group $ownerGroupTitle
	$silent = Set-SPOUser -Site $studentTeamSiteUrl -LoginName $studentUPN -IsSiteCollectionAdmin $true		
    Write-Host " - done"
    Write-Host ""

    $studentSearchSiteUrl =  $classroomSharePointRootSite + "/sites/SearchCenter_"+$firstName+$lastName   
    Write-Host "Creating search center site at $studentSearchSiteUrl"    
    $silent = New-SPOSite -Url $studentSearchSiteUrl -Owner $instructorUPN -StorageQuota 1000 -Title "Search" -Template "SRCHCEN#0" 
    Write-Host " - site created"

    Write-Host " - configuring permissions for student to access site as site owner"
    $site = Get-SPOSite $studentSearchSiteUrl
    $ownerGroup = Get-SPOSiteGroup -site $studentSearchSiteUrl | where {$_.title -like "*Owners"}
	$ownerGroupTitle = $ownerGroup.title
	$silent = Add-SPOUser -Site $studentSearchSiteUrl -LoginName $studentUPN -Group $ownerGroupTitle
	$silent = Set-SPOUser -Site $studentSearchSiteUrl -LoginName $studentUPN -IsSiteCollectionAdmin $true		
    Write-Host " - done"
    Write-Host ""

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