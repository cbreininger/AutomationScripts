$servers=(
  #Add server list here
)

$block={$services= Get-Service av.*
foreach ($service in $services) {
    $serviceName = $service.Name
    $ServicePID = (get-wmiobject win32_service | where { $_.name -eq $serviceName}).processID
    $Process= (Get-Process | select name, id, starttime | select-string $ServicePID)
    $Hostname= Hostname
    Write-Host $Hostname $Process
}}
foreach ($server in $servers){
    Invoke-Command -ComputerName $server -ScriptBlock $block
}
