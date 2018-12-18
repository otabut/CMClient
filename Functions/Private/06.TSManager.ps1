function Check-TSManager {
    Param(
        [Parameter(Mandatory = $false)][Switch]$Silent
    )

    if (-not $Silent) { Write-Host "$(get-date -Format s) | Check TSManager process" -ForegroundColor Cyan }
    
    #Check if TSManager is running
    if (Get-Process -Name TSManager -ErrorAction SilentlyContinue) {
        if (-not $Silent) { Write-Host "$(get-date -Format s) | [WARNING] Another Task Sequence is currently running" -ForegroundColor Yellow }
        return "NotCompliant"
    }
    else {
        if (-not $Silent) { Write-Host "$(get-date -Format s) | no TSManager detected" }
        return "Compliant"
    }
}

function Repair-TSManager {
    #Get-Process -Name TSManager -ErrorAction SilentlyContinue | Stop-Process
    #Write-Host "$(get-date -Format s) | [WARNING] TSManager process has been terminated" -ForegroundColor Yellow
    Write-Host "$(get-date -Format s) | [WARNING] Auto-remediation is not possible" -ForegroundColor Yellow  
}