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

function New-Student($firstName, $lastName, $alternateEmail) {

 $userPrincipalName = $firstName + "." + $lastName + "@" + $classroomDomain
 $userDisplayName = $firstName + " " + $lastName
 $password = "pass@word1"

  # Create the user  
  New-MsolUser -UserPrincipalName $userPrincipalName `
               -DisplayName $userDisplayName `
               -UsageLocation "US" `
               -UserType Member `
               -LicenseAssignment $e5LcenseSku `
               -AlternateEmailAddresses $alternateEmail `
               -Password $password `
               -PasswordNeverExpires $true

}
 

$credential = New-Object -TypeName System.Management.Automation.PSCredential `
                         -ArgumentList $globalAdminAccount, $globalAdminSecurePassword

Connect-MsolService -Credential $credential
Connect-SPOService -Url $classroomSharePointTenantSite -credential $credential


$firstname = "Fred"
$lastName = "Pattison"
$alternateEmail = "tp@aol.com"

New-Student $firstname $lastName $alternateEmail