function Check-Services {
    Param(
        [Parameter(Mandatory = $false)][Switch]$Silent
    )
    
    $Result = "Compliant"
    if (-not $Silent) { Write-Host "$(get-date -Format s) | Check services status" -ForegroundColor Cyan }
    ForEach ($Service in $Configuration.ServicesList.split(',')) {
        $ServiceInfo = Get-WmiObject -Class Win32_Service -Filter "Name='$Service'"
        $StartType = $ServiceInfo.StartMode   ### use of wmi method instead because posh cmdlet is not consistent on all OS versions
        $Status = $ServiceInfo.State
        if ($Status -eq 'Running') {
            if (-not $Silent) { Write-Host "$(get-date -Format s) | $Service : $StartType/$Status" }
        }
        else {
            if (-not $Silent) { Write-Host "$(get-date -Format s) | [WARNING] $Service : $StartType/$Status" -ForegroundColor Yellow }
            $Result = "NotCompliant"
        }
    }
    return $Result
}

function Repair-Services {
    Write-Host "$(get-date -Format s) | [WARNING] Starting auto-remediation..." -ForegroundColor Yellow
    ForEach ($Service in $Configuration.ServicesList.split(',')) {
        $ServiceInfo = Get-WmiObject -Class Win32_Service -Filter "Name='$Service'"
        $StartType = $ServiceInfo.StartMode   ### use of wmi method instead because posh cmdlet is not consistent on all OS versions
        $Status = $ServiceInfo.State
        if ($StartType -ne 'Auto') {
            Set-Service -Name $Service -StartupType Automatic
        }
        if ($Status -ne 'Running') {
            Set-Service -Name $Service -Status Running
        }
    }

    if ((Check-Services -silent) -eq 'Compliant') {
        Write-Host "$(get-date -Format s) | [WARNING] Auto-remediation has been performed successfully" -ForegroundColor Yellow
    }
    else {
        Write-Host "$(get-date -Format s) | [ERROR] Auto-remediation failed" -ForegroundColor Red
    }
}