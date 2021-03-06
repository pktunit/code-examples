$body = ""
$report = gwmi win32_volume -Filter 'drivetype = 3' | select driveletter, @{LABEL='free';EXPRESSION={"{0:N2}" -f ($_.freespace/1GB)} }, @{LABEL='cap';EXPRESSION={"{0:N2}" -f ($_.capacity/1GB)} }
foreach ($line in $report) {
  $free = $line.free
  $drive = $line.driveletter
  $cap = $line.cap
  if (!$drive) {$drive = "?:"}
  
  $body += "[$drive] $free / $cap GB`n"
}

$smtp = "mailcluster.company.com" 
$from = "Company IT <it@company.com>"
$to = "Company IT <it@company.com>"
$datetime = Get-Date -format g
$date = Get-Date -format d
$subject = "$date SQLTEST Free Space: $free GB"


send-MailMessage -SmtpServer $smtp -To $to -From $from -Subject $subject -Body $body -Priority high 
Write-Host $body
