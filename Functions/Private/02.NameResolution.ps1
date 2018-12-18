function Check-NameResolution {
    Param(
        [Parameter(Mandatory = $false)][Switch]$Silent
    )

    if (-not $Silent) { Write-Host "$(get-date -Format s) | Check name resolution" -ForegroundColor Cyan }
   
    $MP = (new-object -comobject 'Microsoft.SMS.Client').GetCurrentManagementPoint()
    $SUP = (Get-ItemProperty -Path "hklm:\software\policies\microsoft\windows\windowsupdate" -Name WUServer).WUServer.split('/')[2].split(':')[0]

    try {
        $MPIPAddress = [System.Net.Dns]::GetHostAddresses($MP).IPAddressToString
        $SUPIPAddress = [System.Net.Dns]::GetHostAddresses($SUP).IPAddressToString
    }
    catch {
    }

    if ([string]::IsNullOrEmpty($MPIPAddress) -or [string]::IsNullOrEmpty( $SUPIPAddress)) {
        if (-not $Silent) { Write-Host "$(get-date -Format s) | [WARNING] MP or SUP names are not correctly resolved" -ForegroundColor Yellow }
        return "NotCompliant"
    }
    else {
        if (-not $Silent) { Write-Host "$(get-date -Format s) | MP and SUP names are successfully resolved" }
        return "Compliant"
    }
}

function Repair-NameResolution {
    Write-Host "$(get-date -Format s) | [WARNING] Auto-remediation is not possible. Please check DNS settings in IP configuration." -ForegroundColor Yellow
}