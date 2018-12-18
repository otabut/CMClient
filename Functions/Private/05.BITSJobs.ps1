function Check-BITSJobs {
    Param(
        [Parameter(Mandatory = $false)][Switch]$Silent
    )

    if (-not $Silent) { Write-Host "$(get-date -Format s) | Check BITS jobs" -ForegroundColor Cyan }
    
    #Check for BITS jobs errors
    if (Get-BitsTransfer -AllUsers -ErrorAction SilentlyContinue | Where-Object { $_.JobState -like "*Error*" }) {
        if (-not $Silent) { Write-Host "$(get-date -Format s) | [WARNING] errors detected on BITS jobs" -ForegroundColor Yellow }
        return "NotCompliant"
    }
    else {
        if (-not $Silent) { Write-Host "$(get-date -Format s) | no BITS jobs running" }
        return "Compliant"
    }
}

function Repair-BITSJobs
{
    Write-Host "$(get-date -Format s) | [WARNING] Starting auto-remediation..." -ForegroundColor Yellow
    Get-BitsTransfer -AllUsers -ErrorAction SilentlyContinue | Where-Object { $_.JobState -like "*Error*" } | Remove-BitsTransfer

    if ((Check-BITSJobs -silent) -eq 'Compliant') {
        Write-Host "$(get-date -Format s) | [WARNING] Auto-remediation has been performed successfully" -ForegroundColor Yellow
    }
    else {
        Write-Host "$(get-date -Format s) | [ERROR] Auto-remediation failed" -ForegroundColor Red
    }
}