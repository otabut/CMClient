function Check-PendingReboot {
    Param(
        [Parameter(Mandatory = $false)][Switch]$Silent
    )

    $ErrorActionPreference = "Stop"
    if (-not $Silent) { Write-Host "$(get-date -Format s) | Check reboot pending" -ForegroundColor Cyan }
    Try {
        ## Setting pending values to false to cut down on the number of else statements
        $CompPendRen, $PendFileRename, $Pending, $SCCM = $false, $false, $false, $false

        ## Making registry connection to the local/remote computer
        $HKLM = [UInt32] "0x80000002"
        $WMI_Reg = [WMIClass] "\root\default:StdRegProv"

        ## If Vista/2008 & Above query the CBS Reg Key
        $CBSRebootPend = $null  ## Setting CBSRebootPend to null since not all versions of Windows has this value
        $WMI_OS = Get-WmiObject -Class Win32_OperatingSystem -Property BuildNumber, CSName  ## Querying WMI for build version
        If ([Int32]$WMI_OS.BuildNumber -ge 6001) {
            $RegSubKeysCBS = $WMI_Reg.EnumKey($HKLM, "SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\")
            $CBSRebootPend = $RegSubKeysCBS.sNames -contains "RebootPending"
        }
            
        ## Query WUAU from the registry
        $RegWUAURebootReq = $WMI_Reg.EnumKey($HKLM, "SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\")
        $WUAURebootReq = $RegWUAURebootReq.sNames -contains "RebootRequired"

        ## Query PendingFileRenameOperations from the registry
        $RegSubKeySM = $WMI_Reg.GetMultiStringValue($HKLM, "SYSTEM\CurrentControlSet\Control\Session Manager\", "PendingFileRenameOperations")
        $PendFileRename = !([string]::IsNullOrEmpty($RegSubKeySM.sValue))

        ## Query ComputerName and ActiveComputerName from the registry
        $ActCompNm = $WMI_Reg.GetStringValue($HKLM, "SYSTEM\CurrentControlSet\Control\ComputerName\ActiveComputerName\", "ComputerName")
        $CompNm = $WMI_Reg.GetStringValue($HKLM, "SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName\", "ComputerName")
        $CompPendRen = $ActCompNm -ne $CompNm

        ## Determine SCCM 2012 Client Reboot Pending Status
        Try {
            $CCMClientSDK = Invoke-WmiMethod -Class CCM_ClientUtilities -Name DetermineIfRebootPending -NameSpace root\ccm\ClientSDK
            If ($CCMClientSDK.IsHardRebootPending -or $CCMClientSDK.RebootPending) {
                $SCCM = $true
            }
            else {
                $SCCM = $false
            }
        }
        Catch {
            $CCMClientSDK = $null
        }

        ## Creating Custom PSObject
        $result = [Ordered]@{
            Computer      = $WMI_OS.CSName
            RebootPending = ($CompPendRen -or $CBSRebootPend -or $WUAURebootReq -or $SCCM)  ### -or $PendFileRename
            Details       = [Ordered]@{
                "Component-Based Servicing" = $CBSRebootPend
                "Windows Update"            = $WUAURebootReq
                "CCM Client SDK"            = $SCCM
                "Pending Computer Rename"   = $CompPendRen
                "Pending File Rename"       = $PendFileRename
                "Pending File Rename Value" = $RegSubKeySM.sValue
            }
        }
 
        if ($result.RebootPending) {
            if (-not $Silent) { Write-Host "$(get-date -Format s) | [WARNING] Reboot is pending" -ForegroundColor Yellow }
            return "NotCompliant"
        }
        else {
            if (-not $Silent) { Write-Host "$(get-date -Format s) | No pending reboot" }
            return "Compliant"
        }
    }
    Catch {
        if (-not $Silent) { Write-Host "$(get-date -Format s) | [ERROR] a problem has occured while checing for potential pending reboot" -ForegroundColor Red }
    }
}

function Repair-PendingReboot {
    Write-Host "$(get-date -Format s) | [WARNING] Auto-remediation is not possible. Please unmonitor the server and reboot it at the most convenient time." -ForegroundColor Yellow
}