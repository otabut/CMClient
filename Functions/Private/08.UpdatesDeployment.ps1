function Check-UpdatesDeployment {
    Param(
        [Parameter(Mandatory = $false)][Switch]$Silent
    )

    if (-not $Silent) { Write-Host "$(get-date -Format s) | Check updates deployment" -ForegroundColor Cyan }

    #Check log file
    Get-ChildItem -Path "$env:windir\CCM\logs\" -Filter "*UpdatesDeployment*" | ForEach-Object {$Content += Get-Content $_.FullName}

    $ErrorCodes = $Content -match '0x800f0831|0x87D00692|0x87D00664|0x80070070' | %{$_.split('(')[1].split(')')[0]} | select -Unique

    if ($ErrorCodes.count -eq 0) {
        return "Compliant"
    }
    else {
        ForEach ($ErrorCode in $ErrorCodes) {
            $ErrorDescription = ($Configuration.ErrorCodes | where-object {$_.code -eq $ErrorCode}).Description | Select-Object -first 1
            $ErrorMessage = $ErrorCode + " - " + $ErrorDescription
            if (-not $Silent) { Write-Host "$(get-date -Format s) | [WARNING] $ErrorMessage" -ForegroundColor Yellow }
        }
        return "NotCompliant"
    }
}

function Repair-UpdatesDeployment {
    Write-Host "$(get-date -Format s) | [WARNING] Auto-remediation is not implemented yet" -ForegroundColor Yellow
}