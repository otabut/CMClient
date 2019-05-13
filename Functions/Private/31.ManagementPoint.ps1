function Check-ManagementPoint {
    Param(
        [Parameter(Mandatory = $false)][Switch]$Silent
    )

    if (-not $Silent) { Write-Host "$(get-date -Format s) | Check communications with MP" -ForegroundColor Cyan }
        
    #Check log file
    Get-ChildItem -Path "$env:windir\CCM\logs\" -Filter "*StateMessage*" | ForEach-Object {$Content += Get-Content $_.FullName}
    
    if ($Content -match 'Successfully forwarded State Messages to the MP') {
        if (-not $Silent) { Write-Host "$(get-date -Format s) | State messages are successfully forwarded to MP" }
        return "Compliant"
    }
    else {
        if (-not $Silent) { Write-Host "$(get-date -Format s) | [WARNING] State messages are NOT forwarded to MP" -ForegroundColor Yellow }
        return "NotCompliant"
    }
}

function Repair-ManagementPoint {
    Write-Host "$(get-date -Format s) | [WARNING] Starting auto-remediation..." -ForegroundColor Yellow
    Write-Host "$(get-date -Format s) | Trying to restart CCMEXEC service..."
    Restart-Service CcmExec
    Write-Host "$(get-date -Format s) | Waiting for 90 seconds..."
    Start-Sleep -Seconds 90

    if ((Check-ManagementPoint -silent) -eq 'Compliant') {
        Write-Host "$(get-date -Format s) | [WARNING] Auto-remediation has been performed successfully" -ForegroundColor Yellow
    }
    else {
        Write-Host "$(get-date -Format s) | [ERROR] Auto-remediation failed" -ForegroundColor Red
    }
}