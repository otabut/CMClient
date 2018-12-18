function Check-SoftwareUpdatesPoint {
    Param(
        [Parameter(Mandatory = $false)][Switch]$Silent
    )

    if (-not $Silent) { Write-Host "$(get-date -Format s) | Check SUP connection" -ForegroundColor Cyan }
    $Status = "Compliant"

    Try {
        $WUServer = (Get-ItemProperty -Path "hklm:\software\policies\microsoft\windows\windowsupdate" -Name WUServer).WUServer
        if ([string]::IsNullOrEmpty($WUServer)) {
            if (-not $Silent) { Write-Host "$(get-date -Format s) | [ERROR] Windowsupdate registry key is empty" -ForegroundColor Red }
        }
        else {
            if ($WUServer -like "$($Configuration.WUServerMask)") {
                if (-not $Silent) { Write-Host "$(get-date -Format s) | WSUS attachment is $WUServer" }
                Try {
                    (New-Object System.Net.WebClient).DownloadString("$($WUServer)/ClientWebService/client.asmx") | Out-Null
                    if (-not $Silent) { Write-Host "$(get-date -Format s) | $WUServer successfully connected" }
                }
                Catch {
                    if (-not $Silent) { Write-Host "$(get-date -Format s) | [ERROR] Unable to connect to WSUS server: $($WUServer) - $($_.Exception.Message)" -ForegroundColor Red }
                    $Status = "NotCompliant"
                }
            }
            else {
                if (-not $Silent) { Write-Host "$(get-date -Format s) | [WARNING] WSUS attachment is $WUServer" -ForegroundColor Yellow }
                $Status = "NotCompliant"
            }
        }
    }
    Catch {
        if (-not $Silent) { Write-Host "$(get-date -Format s) | [ERROR] Windowsupdate registry key not found" -ForegroundColor Red }
        $Status = "NotCompliant"
    }

    return $Status
}

function Repair-SoftwareUpdatesPoint {
    Write-Host "$(get-date -Format s) | [WARNING] Auto-remediation is not possible. Check GPO with Resultant Set Of Policy to troubleshoot the issue." -ForegroundColor Yellow
}