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
    Write-Host "$(get-date -Format s) | [WARNING] Auto-remediation is not implemented yet" -ForegroundColor Yellow
}