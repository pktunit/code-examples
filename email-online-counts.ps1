$clients = "CSCT", "CUCM", "THRA", "THSK"
$start_example = "(E.g. 2014-01-01)"
$format = "yyyy-MM-dd"
[string]$date = Read-Host "Enter a Date in the month you wish to get counts for.`nUse the followin format: $format.  $start_example"
if ($date -eq "") {
    $date = (Get-Date).AddMonths(-1)
}
$startdate = Get-Date $date -Day 1 -Hour 0 -Minute 0 -Second 0
$enddate = (($startdate).AddMonths(1).AddSeconds(-1))

# Begin Date Validation #
function confirm_exit($exit_message) {
    Write-Host "`n$exit_message`n"
    $exit = Read-Host "Press Enter to key to quit"
    Exit
}
# End  Date Validation #
rasdial "Company VPN" rekon rekonsupport99!

foreach ($client in $clients) {
    $database = "r2k_" + $client + "_Online"
    $sqlconn = New-Object System.Data.SqlClient.SqlConnection
    $sqlconn.ConnectionString = "Server=206681-2;Database=$database;Integrated Security=True"
    $sqlconn.Open()
    $getname = New-Object System.Data.SqlClient.SqlCommand
    $getname.CommandText = "SELECT clientname FROM kclient"
    $getname.Connection = $sqlconn
    $name = $getname.ExecuteScalar()
    $getreleases = New-Object System.Data.SqlClient.SqlCommand
    $getreleases.CommandText = @"
SELECT COUNT(*) AS count FROM kbatitem
WHERE ISNULL(ddownload,dbatch) BETWEEN '$startdate' and '$enddate'
"@
    $getreleases.Connection = $sqlconn
    $releases = $getreleases.ExecuteScalar()
    $getassignments = New-Object System.Data.SqlClient.SqlCommand
    $getassignments.CommandText = @"
SELECT COUNT(*) AS count FROM abatitem
WHERE ISNULL(ddownload,dbatch) BETWEEN '$startdate' and '$enddate' 
ORDER BY count
"@
    $getassignments.Connection = $sqlconn
    $assignments = $getassignments.ExecuteScalar()
    $sqlconn.Close()
    # Fix common name for THSK
    if ($client -eq "THSK") {
        $name = "TRUEHOME SOLUTIONS,LLC"
    }
    $body = @"
$name

$assignments  Assignments
$releases Releases
"@
    $smtp = "mail.company.com" 
    $to = "Treasury <Treasury@copmany.com>"
    $cc = "Jason <jason@company.com>"
    $bcc = "Rekon IT <it@company.com>"
    $from = "Rekon IT <it@company.com>"
    $month = Get-Date $date -format Y
    $subject = "Company Online $month File Count for $client"
    
    send-MailMessage -SmtpServer $smtp -To $to -From $from -Subject $subject -Body $body -Cc $cc -Bcc $bcc -Priority high 
}

rasdial "Company VPN" /DISCONNECT
$exit = Read-Host "Press Enter key to quit"