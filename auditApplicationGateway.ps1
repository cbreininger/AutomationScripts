param (
    [Parameter(mandatory=$true)]
    [String]$subscription,
    [Parameter(mandatory=$true)]
    [String]$vnet
)
Connect-AzAccount
Select-AzSubscription -Subscription $subscription
$appGws=Get-AzApplicationGateway
foreach ($appGw in $appGws) {
    $bkPools=$appGw.BackendAddressPools
    foreach ($bkPool in $bkPools) {
        $addresses=$bkPool.BackendAddresses
        foreach ($address in $addresses) {
            $IPTest=Test-AzPrivateIPAddressAvailability -ResourceGroupName $appGw.ResourceGroupName -VirtualNetworkName $vnet -IPAddress $address.IpAddress
            if ($IPTest.Available) {
                $action="REMOVE"
                $color = "RED"
            } else { 
                $action="ACTIVE" 
                $color = "GREEN"
            }
            write-host "$($appGw.Name) - $($bkPool.Name) - $($address.IpAddress) - $($action) " -ForegroundColor $color
        }
    Write-Host "======================================================================================================================"
    }
}