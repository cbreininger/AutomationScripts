$hash=""
$certName=""
$serverList= ()

$scriptBlock={ 
    param (
        [Parameter(mandatory=$true)]
        [String]$hashCert,
        [Parameter(mandatory=$true)]
        [String]$certName
    )
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls -bor [System.Net.SecurityProtocolType]::Tls11 -bor [System.Net.SecurityProtocolType]::Tls12 -bor [System.Net.SecurityProtocolType]::Ssl -bor [System.Net.SecurityProtocolType]::Tls13
    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
    foreach ($listener in (Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue | sls "443")) {
        $port=$listener.toString().split("??")[2]
        $site ="https://localhost:$($port)"
        $request = [Net.HttpWebRequest]::Create($site)
        try 
        {
            $request.GetResponse() | Out-Null
        } catch { }
        $expDate = $request.ServicePoint.Certificate.GetExpirationDateString()
        $certName = $request.ServicePoint.Certificate.GetName()
        $certThumbprint = $request.ServicePoint.Certificate.GetCertHashString()
        $request.Abort()
        if ($certName -like $certName) {
            write-host "$(hostname) --> $site"
            if ($certThumbprint -like $hashCert) {
                write-host "OK!" -ForegroundColor Green
             } else {
                write-host "Error!" -ForegroundColor Red
             }
        }
    }
}

foreach ($server in $serverList) {
    Invoke-command -computerName $server -scriptblock $scriptBlock -ArgumentList $hash,$certName
} 
