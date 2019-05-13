function Check-AgentConfiguration {
    Param(
        [Parameter(Mandatory = $false)][Switch]$Silent
    )

    if (-not $Silent) { Write-Host "$(get-date -Format s) | Check SCCM agent configuration" -ForegroundColor Cyan }

    #Check Site code
    $SiteCode = (new-object -comobject 'Microsoft.SMS.Client').GetAssignedSite()
    if ($SiteCode -eq $Configuration.SiteCode) {
        if (-not $Silent) { Write-Host "$(get-date -Format s) | Site code : $SiteCode" }
    }
    else {
        if (-not $Silent) { Write-Host "$(get-date -Format s) | [WARNING] Site code is $SiteCode (Expected: $($Configuration.SiteCode))" -ForegroundColor Yellow }
    }

    #Get Management Point
    $MP = (new-object -comobject 'Microsoft.SMS.Client').GetCurrentManagementPoint()
    if (-not $Silent) { Write-Host "$(get-date -Format s) | Management Point : $MP" }

    #Check client version
    $ClientVersion = (Get-WmiObject -Namespace root/ccm SMS_Client).ClientVersion
    if ($ClientVersion -eq $Configuration.AgentVersion) {
        if (-not $Silent) { Write-Host "$(get-date -Format s) | Client version : $ClientVersion" }
        $Status = "Compliant"
    }
    else {
        if (-not $Silent) { Write-Host "$(get-date -Format s) | [WARNING] Client version is obsolete (Current: $ClientVersion; Expected: $($Configuration.AgentVersion))" -ForegroundColor Yellow }
        $Status = "NotCompliant"
    }

    #Get SCCM log settings
    if (-not $Silent) { Write-Host "$(get-date -Format s) | Log max size : $([Math]::Round(((Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\CCM\Logging\@Global').LogMaxSize) / 1000)) MB" }
    if (-not $Silent) { Write-Host "$(get-date -Format s) | Log max history : $((Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\CCM\Logging\@Global').LogMaxHistory)" }

    #Get SCCM cache size
    if (-not $Silent) { Write-Host "$(get-date -Format s) | Cache max size : $("{0:N0} MB" -f (New-Object -ComObject UIResource.UIResourceMgr).GetCacheInfo().TotalSize)" }
    if (Test-Path -Path $env:windir\ccmcache) {
        if (-not $Silent) { Write-Host "$(get-date -Format s) | Cache current size : $("{0:N0} MB" -f ((Get-ChildItem $env:windir\ccmcache -Recurse | Where-Object { ! $_.PSIsContainer } | Measure-Object -Property Length -Sum -ErrorAction Stop).Sum / 1MB))" }
    }

    Return $Status
}

function Repair-AgentConfiguration {
    Write-Host "$(get-date -Format s) | [WARNING] Auto-remediation is not implemented yet" -ForegroundColor Yellow
}
