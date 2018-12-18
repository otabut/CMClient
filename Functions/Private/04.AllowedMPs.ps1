function Check-AllowedMPs {
    Param(
        [Parameter(Mandatory = $false)][Switch]$Silent
    )
    
    if (-not $Silent) { Write-Host "$(get-date -Format s) | Check AllowedMPs regkey" -ForegroundColor Cyan }
   
    if ((Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\CCM').AllowedMPs) {
        if (-not $Silent) { Write-Host "$(get-date -Format s) | [WARNING] HKLM:\SOFTWARE\Microsoft\CCM\AllowedMPs exists and should be removed" -ForegroundColor Yellow }
        return "NotCompliant"
    }
    else {
        if (-not $Silent) { Write-Host "$(get-date -Format s) | no registry key HKLM:\SOFTWARE\Microsoft\CCM\AllowedMPs" }
        return "Compliant"
    }
}

function Repair-AllowedMPs
{
    Write-Host "$(get-date -Format s) | [WARNING] Starting auto-remediation..." -ForegroundColor Yellow
    remove-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\CCM' -Name AllowedMPs

    if ((Check-AllowedMPs -silent) -eq 'Compliant') {
        Write-Host "$(get-date -Format s) | [WARNING] Auto-remediation has been performed successfully" -ForegroundColor Yellow
    }
    else {
        Write-Host "$(get-date -Format s) | [ERROR] Auto-remediation failed" -ForegroundColor Red
    }
}