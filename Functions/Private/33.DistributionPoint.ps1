function Check-DistributionPoint {
    Param(
        [Parameter(Mandatory = $false)][Switch]$Silent
    )

    if (-not $Silent) { Write-Host "$(get-date -Format s) | Check Distribution Points" -ForegroundColor Cyan }

    #Check log file
    Get-ChildItem -Path "$env:windir\CCM\logs\" -Filter "*LocationServices*" | ForEach-Object {$Content += Get-Content $_.FullName}
    
    if ($Content -match 'Calling back with the following distribution points') {
        $DPs = (($Content -match 'Distribution point=').split("'") -match 'http') | ForEach-Object {$_.split('/')[2]} | Select-Object -unique
        $DPs | ForEach-Object {if (-not $Silent) { Write-Host "$(get-date -Format s) | Distribution Point : $_" }}
        return "Compliant"
    }
    else {
        if (-not $Silent) { Write-Host "$(get-date -Format s) | No DP associated to this SCCM agent's boundary" -ForegroundColor Yellow }
        return "NotCompliant"
    }
}

function Repair-DistributionPoint {
    Write-Host "$(get-date -Format s) | [WARNING] Auto-remediation is not possible. Please check boundaries and boundary groups in SCCM console." -ForegroundColor Yellow
}