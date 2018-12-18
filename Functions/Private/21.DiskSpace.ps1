function Check-DiskSpace {
    Param(
        [Parameter(Mandatory = $false)][Switch]$Silent
    )

    if (-not $Silent) { Write-Host "$(get-date -Format s) | Check disk space" -ForegroundColor Cyan }
    $driveC = Get-WmiObject -Class Win32_LogicalDisk | Where-Object {$_.DeviceID -eq "$env:SystemDrive"} | Select-Object FreeSpace
    #$freeSpace = (($driveC.FreeSpace / $driveC.Size) * 100)  ### %
    $freeSpace = [math]::Round($driveC.FreeSpace / 1024 / 1024)  ### MB
    if ($freeSpace -lt $Configuration.DiskSpaceThreshold) {
        if (-not $Silent) { Write-Host "$(get-date -Format s) | [WARNING] Free space is lower than $($Configuration.DiskSpaceThreshold) MB" -ForegroundColor Yellow }
        return "NotCompliant"
    }
    else {
        if (-not $Silent) { Write-Host "$(get-date -Format s) | Free space : $freeSpace MB" }
        return "Compliant"
    }
}

function Repair-DiskSpace {
    Write-Host "$(get-date -Format s) | [WARNING] Auto-remediation is not implemented yet. Please free some disk space on system drive." -ForegroundColor Yellow
}