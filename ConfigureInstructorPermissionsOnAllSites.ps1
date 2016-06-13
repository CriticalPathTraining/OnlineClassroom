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

$instructorUPN = $globalAdminAccount 

function Configure-Site-Permissions($siteCollectionUrl){

    if ($siteCollectionUrl -like '*/sites/*') { 
        Write-Host " - configuring instructor permissions for $siteCollectionUrl"
        $ownerGroup = Get-SPOSiteGroup -site $siteCollectionUrl | where {$_.title -like "*Owners"}
	    $ownerGroupTitle = $ownerGroup.title
	    $silent = Add-SPOUser -Site $siteCollectionUrl -LoginName $instructorUPN -Group $ownerGroupTitle
	    $silent = Set-SPOUser -Site $siteCollectionUrl -LoginName $instructorUPN -IsSiteCollectionAdmin $true		
        Write-Host " - done"
        Write-Host ""

    }

    
    
}

# create new log file 

$credential = New-Object -TypeName System.Management.Automation.PSCredential `
                         -ArgumentList $globalAdminAccount, $globalAdminSecurePassword

Connect-SPOService -Url $classroomSharePointTenantSite -credential $credential

$siteCollections = Get-SPOSite

foreach($siteCollection in $siteCollections) { 
    Configure-Site-Permissions $siteCollection.Url   
}