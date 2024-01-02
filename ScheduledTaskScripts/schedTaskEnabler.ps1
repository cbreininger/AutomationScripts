$taskName = #Add task name here
$servers = @(
  #Add server list sepparated by comma 
)
foreach ($server in $servers) {
    $schedBounce = Get-ScheduledTask -CimSession $Server -TaskName $taskName
    if ($schedBounce.State -eq "Disabled") {
        Enable-ScheduledTask -CimSession $server -TaskName $taskName
        $schedBounce = Get-ScheduledTask -CimSession $Server -TaskName $taskName
        Write-Host "Server: $($server) ---> $($schedBounce.State)"
      }
}
