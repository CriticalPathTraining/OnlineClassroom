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

$e5LcenseSku = $classroomDomainName + ":ENTERPRISEPREMIUM"

Write-Host $classroomDomainName
Write-Host $classroomDomain
Write-Host $classroomSharePointRootSite 
Write-Host $classroomSharePointTenantSite 
Write-Host $globalAdminAccountName 
Write-Host $globalAdminAccount
Write-Host $globalAdminAccountPassword 
Write-Host $e5LcenseSku

function Create-Student-Sites($firstName, $lastName){

    $studentUPN = $firstName + "." + $lastName + "@" + $classroomDomain    
    $instructorUPN  = $globalAdminAccount

    $studentTeamSiteUrl =  $classroomSharePointRootSite + "/sites/TeamSite_"+$firstName+$lastName  
 
    Write-Host "Creating site"
    New-SPOSite -Url $studentTeamSiteUrl -Owner $instructorUPN -StorageQuota 1000 -Title "Team Site" -Template "STS#0" 
    Write-Host "Site created"

    Write-Host "Adding instructor as site owner"
    $site = Get-SPOSite $studentTeamSiteUrl
    $ownerGroup = Get-SPOSiteGroup -site $studentTeamSiteUrl | where {$_.title -like "*Owners"}
	$ownerGroupTitle = $ownerGroup.title
	Add-SPOUser -Site $studentTeamSiteUrl -LoginName $studentUPN -Group $ownerGroupTitle
	Set-SPOUser -Site $studentTeamSiteUrl -LoginName $studentUPN -IsSiteCollectionAdmin $true		
}


$credential = New-Object -TypeName System.Management.Automation.PSCredential `
                         -ArgumentList $globalAdminAccount, $globalAdminSecurePassword

Connect-MsolService -Credential $credential
Connect-SPOService -Url $classroomSharePointTenantSite -credential $credential


$firstname = "Fred"
$lastName = "Pattison"

Create-Student-Sites $firstname $lastName