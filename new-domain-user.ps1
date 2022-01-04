# This script creates a new user, adds them to the $defaultgroups,
# sets permissions so Authenitcated Users can see group membership, and
# creates the user folder in the $userdir
Import-Module ActiveDirectory

$defaultpassword = "CompanyNew123"
$defaultgroups = @("CompanyEmployees", "CompanyGroup")
$adp = @("bc0ac240-79a9-11d0-9020-00c04fc2d4cf", "77b5b886-944a-11d1-aebd-0000f80367c1", "59ba2f42-79a2-11d0-9020-00c04fc2d3cf")
$userdir = "\\phoenix\users"

# Read in data
$firstname = Read-Host "First name: "
$lastname = Read-Host "Last name: "
$username = Read-Host "Username: "
$title = Read-Host "Title: "
$dept = Read-Host "Department: (PRG, QA)"

# Format data
$username = $username.ToLower()
$lastname = (Get-Culture).TextInfo.ToTitleCase($lastname)
$firstname = (Get-Culture).TextInfo.ToTitleCase($firstname)
$name = "$firstname $lastname"
$dept = $dept.ToUpper()

# Create the user account
New-ADUser -SAMAccountName $username -DisplayName $name -name $name -givenname $firstname -surname $lastname `
-UserPrincipalName ($username + �@rekon.com�) -Path "OU=Users,OU=User Accounts,DC=company,DC=com" `
-Enabled $true -Company "Company Technologies" -Title $title -description $title -Department $dept `
-AccountPassword (ConvertTo-SecureString $defaultpassword -AsPlainText -Force)

# Sleep and wait for user object to be created
Start-Sleep -m 1000

# Add user to the default groups
foreach($group in $defaultgroups) {
    Add-ADGroupMember -Identity $group -Members $username
}

# Set read access to 'Allow' for the following groups
# Read general information, Read group membership, Read personal information
$acl = Get-Acl "AD:\cn=$name,ou=Users,ou=User Accounts,dc=company,dc=com"
$nta = New-Object System.Security.Principal.NTAccount("Authenticated Users")
$sid = $nta.Translate([System.Security.Principal.SecurityIdentifier])
foreach($permission in $adp) {
    $guid = New-Object guid $permission
    $ace = New-Object System.DirectoryServices.ActiveDirectoryAccessRule($sid,"ReadProperty","Allow",$guid,"None")
    $acl.AddAccessRule($ace)
}
Set-Acl -AclObject $acl -Path "AD:\cn=$name,ou=Users,ou=User Accounts,dc=rekon,dc=com"

# Create user folder in $userdir
$foldername = $username.substring(0,1).toupper() + $username.substring(1,$username.length-2).tolower() + $username.substring($username.length-1).toupper()

New-Item "$userdir\$foldername" -type directory

# Create Outlook signature
New-Item "$userdir\$foldername\Signatures" -type directory
New-Item "$userdir\$foldername\Signatures\$username@rekon.com_files" -type directory

$sourcedir = "\\titan\software\Signatures"
$destdir = "$userdir\$foldername\Signatures"
$exts = @("htm", "rtf", "txt")
$files = @("colorschememapping.xml", "filelist.xml", "themedata.thmx")

foreach ($ext in $exts) {
    Get-Content "$sourcedir\username@company.com.$ext" | `
    Foreach-Object { $_ -replace "username",$username -replace "fullname",$name -replace "position",$title } | `
    Set-Content "$destdir\$username@company.com.$ext"
}
foreach ($file in $files) {
    Get-Content "$sourcedir\username@company.com_files\$file" | `
    Foreach-Object { $_ -replace "username",$username -replace "fullname",$name -replace "position",$title } | `
    Set-Content "$destdir\$username@company.com_files\$file"
}

# Display result
Get-ADUser -Identity $username -Properties Department,Description,Title,MemberOf
#Get-ADPrincipalGroupMembership $username | select @{Name="Groups";Expression={$_."name"}}
Get-Item "$userdir\$foldername"
Write-Host "`nActive Directory setup has been completed`nThe password has been set to: $defaultpassword`n"
$exit = Read-Host "`nPress any key to exit`n"