function Check-ScanStatus {
    Param(
        [Parameter(Mandatory = $false)][Switch]$Silent
    )

    if (-not $Silent) { Write-Host "$(get-date -Format s) | Check scan status" -ForegroundColor Cyan }

    #Check log file
    Get-ChildItem -Path "$env:windir\CCM\logs\" -Filter "*WUAHandler*" | ForEach-Object {$Content += Get-Content $_.FullName}

    if ($Content -match 'Successfully completed scan') {
        if (-not $Silent) { Write-Host "$(get-date -Format s) | Scan status is successfull" }
        return "Compliant"
    }
    else {
        $ErrorMessage = $Content -match 'Scan failed with error' | Select-Object -last 1
        if ($ErrorMessage) {
            $ErrorMessage = $ErrorMessage.split('[').split(']')[2]
            $ErrorCode = $ErrorMessage.split('=')[1].split('.')[0].trim()
            $ErrorDescription = ($Configuration.ErroCodes | where-object {$_.code -eq $ErrorCode}).Description | Select-Object -first 1
            $ErrorMessage = $ErrorMessage + " - " + $ErrorDescription
            if (-not $Silent) { Write-Host "$(get-date -Format s) | [WARNING] $ErrorMessage" -ForegroundColor Yellow }
            return "NotCompliant"
        }
        else {
            return "Compliant"
        }
    }
}

function Repair-ScanStatus {
    Write-Host "$(get-date -Format s) | [WARNING] Auto-remediation is not implemented yet" -ForegroundColor Yellow
}
