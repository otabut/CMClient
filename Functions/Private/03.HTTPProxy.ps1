function Check-HTTPProxy {
    Param(
        [Parameter(Mandatory = $false)][Switch]$Silent
    )
    
    if (-not $Silent) { Write-Host "$(get-date -Format s) | Check winhttp proxy" -ForegroundColor Cyan }
    
    #Check no HTTP Proxy is configured
    $result = Invoke-Expression "netsh winhttp show proxy"
    if (!($result -like '*Direct access (no proxy server)*')) {
        if ($result -match $($Configuration.ProxyBypass).replace('*', '\*')) {
            if (-not $Silent) { Write-Host "$(get-date -Format s) | HTTP Proxy configured with exception" }
            return "Compliant"
        }
        else {
            if (-not $Silent) { Write-Host "$(get-date -Format s) | [ERROR] HTTP Proxy configured" -ForegroundColor Red }
            return "NotCompliant"
        }
    }
    else {
        if (-not $Silent) { Write-Host "$(get-date -Format s) | no HTTP Proxy configured" }
        return "Compliant"
    }
}

function Repair-HTTPProxy {
    Write-Host "$(get-date -Format s) | [WARNING] Starting auto-remediation..." -ForegroundColor Yellow
    $result = Invoke-Expression "netsh winhttp show proxy"
    $netsh = ($result -match "Proxy Server").split(':').trim()
    $Proxy = $netsh[1] + ':' + $netsh[2]
    $netsh = ($result -match "Bypass List").split(':').trim()
    if ($netsh[1] -eq '(none)') {
        $Bypass = $Configuration.ProxyBypass
    }
    else {
        $Bypass = $netsh[1].replace(',', ';') + ';' + $Configuration.ProxyBypass
    }
    $result = netsh winhttp set proxy $Proxy $Bypass

    if ((Check-HTTPProxy -Silent) -eq "Compliant") {
        Write-Host "$(get-date -Format s) | [WARNING] Auto-remediation has been performed successfully" -ForegroundColor Yellow
    }
    else {
        Write-Host "$(get-date -Format s) | [ERROR] Auto-remediation failed" -ForegroundColor Red
    }
}