$taskName = #Add scheduled task name here
$outputFile = "~\Desktop\$($taskName).csv" #The script will create an output file on this path 
$servers = @(
	# Add server list sepparated by comma
)
if (Test-Path $outputFile) {
    Remove-Item -Path $outputFile
}
Add-Content -Path $outputFile -Value "Server,State,Days Interval,Last Run Time,Last Task Result"
Write-Host "Server$([char]9)$([char]9)$([char]9)State$([char]9)Days Interval$([char]9)Last Run Time$([char]9)$([char]9)Last Task Result"
Write-Host "======$([char]9)$([char]9)$([char]9)=====$([char]9)=============$([char]9)=============$([char]9)$([char]9)================"
foreach ($server in $servers) {
    $schedBounce = Get-ScheduledTask -CimSession $Server -TaskName $taskName
    $taskInfo = Get-ScheduledTaskInfo -CimSession $server -TaskName $taskName
    foreach ($bounceTrigger in $schedBounce.Triggers) {
        Add-Content -Path $outputFile -Value "$($server),$($schedBounce.State),$($bounceTrigger.DaysInterval),$($taskInfo.LastRunTime),$($taskInfo.LastTaskResult)"
        Write-Host "$($server)$([char]9)$([char]9)$($schedBounce.State)$([char]9)$($bounceTrigger.DaysInterval)$([char]9)$([char]9)$([char]9)$([char]9)$($taskInfo.LastRunTime)$([char]9)$($taskInfo.LastTaskResult)"
    }
}
