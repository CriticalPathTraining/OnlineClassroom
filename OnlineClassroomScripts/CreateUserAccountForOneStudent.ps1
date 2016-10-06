Clear-Host 

$firstName = "Bob"
$lastName = "White"
$alternateEmail = "bw@gmail.com"

$classroomDomainName = "CptClassroom0812"
$globalAdminAccountName = "Instructor"
$globalAdminPassword = "pass@word1"

$classroomDomain = $classroomDomainName + ".onMicrosoft.com"

$globalAdminAccount = $globalAdminAccountName + "@" + $classroomDomain 
$globalAdminSecurePassword = ConvertTo-SecureString -String $globalAdminPassword -AsPlainText -Force

$e5LcenseSku = $classroomDomainName + ":ENTERPRISEPREMIUM"

function New-Student($firstName, $lastName, $alternateEmail) {

 $userDisplayName = $firstName + " " + $lastName
 
 $firstNameClean = $firstName -replace " ", ""
 $firstNameClean = $firstNameClean -replace "'", ""
 
 $lastNameClean = $lastName -replace " ", ""
 $lastNameClean = $lastNameClean -replace "'", ""

 $userPrincipalName = $firstNameClean + "." + $lastNameClean + "@" + $classroomDomain
 $password = "pass@word1"

 # Create new user account for student 
 New-MsolUser -FirstName $firstName `
              -LastName $lastName `
              -UserPrincipalName $userPrincipalName `
              -DisplayName $userDisplayName `
              -UsageLocation "US" `
              -UserType Member `
              -LicenseAssignment $e5LcenseSku `
              -AlternateEmailAddresses $alternateEmail `
              -Password $password `
              -PasswordNeverExpires $true `
              -ForceChangePassword $false

 # write user info for student to log file
 "Student: $userDisplayName" | Out-File $LogFilePath -Append
 "Login: $userPrincipalName" | Out-File $LogFilePath -Append
 "Password: $password" | Out-File $LogFilePath -Append
 "Alt Email: $alternateEmail" | Out-File $LogFilePath -Append
 "" | Out-File $LogFilePath -Append
 "" | Out-File $LogFilePath -Append
}

# create new log file 
$CurrentDirectory = Get-Location 
$LogFilePath = ("{0}\StudentLog.$firstName.$lastName.txt" -f $CurrentDirectory.Path)
"Log of created student account" | Out-File $LogFilePath
"" | Out-File $LogFilePath -Append

$credential = New-Object -TypeName System.Management.Automation.PSCredential `
                         -ArgumentList $globalAdminAccount, $globalAdminSecurePassword

Connect-MsolService -Credential $credential

New-Student $firstName $lastName $alternateEmail