$username = "asasr"
$name = "Asas Raza"
$title = "Quality Assurance Technician"
$userdir = "\\phoenix\users"
$foldername = $username.substring(0,1).toupper() + $username.substring(1,$username.length-2).tolower() + $username.substring($username.length-1).toupper()

$sourcedir = "\\titan\software\Signatures"
$destdir = "$userdir\$foldername\Signatures"

New-Item "$userdir\$foldername\Signatures" -type directory
New-Item "$userdir\$foldername\Signatures\$username@Company.com_files" -type directory

$exts = @("htm", "rtf", "txt")
$files = @("colorschememapping.xml", "filelist.xml", "themedata.thmx")

foreach ($ext in $exts) {
    Get-Content "$sourcedir\username@rekon.com.$ext" | Foreach-Object { $_ -replace "username",$username -replace "fullname",$name -replace "position",$title } | Set-Content "$destdir\$username@rekon.com.$ext"
}
foreach ($file in $files) {
    Get-Content "$sourcedir\username@rekon.com_files\$file" | Foreach-Object { $_ -replace "username",$username -replace "fullname",$name -replace "position",$title } | Set-Content "$destdir\$username@rekon.com_files\$file"
}