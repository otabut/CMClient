function Check-WMI {
    Param(
        [Parameter(Mandatory = $false)][Switch]$Silent
    )

    if (-not $Silent) { Write-Host "$(get-date -Format s) | Check WMI" -ForegroundColor Cyan }
    $Status = "Compliant"

    $StatusMessage = "WMI repository is CONSISTENT"
    $Color = "White"
    $result = winmgmt /verifyrepository
    switch -wildcard ($result) {
        # Always fix if this returns inconsistent
        "*inconsistent*" { $StatusMessage = "WMI repository is INCONSISTENT"; $Color = "Red"; $StatusCode = 81 } # English
        "*not consistent*" { $StatusMessage = "WMI repository is INCONSISTENT"; $Color = "Red"; $StatusCode = 81 } # English
        # Add more languages as I learn their value
    }
    if (-not $Silent) { Write-Host "$(get-date -Format s) | $StatusMessage" -ForegroundColor $Color }

    Try {
        Get-WmiObject Win32_ComputerSystem -ErrorAction Stop | out-null
        if (-not $Silent) { Write-Host "$(get-date -Format s) | Successfully connected to WMI namespace root\cimv2 and class Win32_ComputerSystem" }
    }
    Catch {
        if (-not $Silent) { Write-Host "$(get-date -Format s) | [ERROR] Failed to connect to WMI namespace root\cimv2 and class Win32_ComputerSystem" -ForegroundColor Red }
        $Status = "NotCompliant"
    }

    Try {
        Get-WmiObject -Namespace root/ccm -Class SMS_Client -ErrorAction Stop | out-null
        if (-not $Silent) { Write-Host "$(get-date -Format s) | Successfully connected to WMI namespace root\ccm and class SMS_Client" }
    }
    Catch {
        if (-not $Silent) { Write-Host "$(get-date -Format s) | [ERROR] Failed to connect to WMI namespace root\ccm and class SMS_Client" -ForegroundColor Red }    ###Client reinstall needed
        $Status = "NotCompliant"
    }
 
    return $Status
}

function Repair-WMI {
    Write-Host "$(get-date -Format s) | [WARNING] Auto-remediation is not implemented yet" -ForegroundColor Yellow
}