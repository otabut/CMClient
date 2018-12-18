Function Get-CMUpdates {
    
    <#
    .SYNOPSIS
        Allows to trigger list available software updates on SCCM agent
    .DESCRIPTION
    .LINK    
    .NOTES
    .PARAMETER Server
        Allow to specify a target computer
    .PARAMETER Usernmae
        Allow to specify an alternate user account
    .PARAMETER Password
        Allow to specify an alternate password
    .EXAMPLE
        Get-CMUpdates
    .EXAMPLE
        Get-CMUpdates -Server MyServer1
    .EXAMPLE
        get-content .\serverlist.txt | Get-CMUpdates -Username MyUser -Password MyPassword
    #>

    Param(
        [Parameter(Mandatory=$false,ValueFromPipeline=$true)][ValidateNotNullOrEmpty()][String]$Server,
        [Parameter(Mandatory=$false)][ValidateNotNullOrEmpty()][String]$Username,
        [Parameter(Mandatory=$false)][ValidateNotNullOrEmpty()][String]$Password
    )
    
    process {
        if ([string]::IsNullOrEmpty($Server)) {
            $Server = $env:COMPUTERNAME
        }

        if ($Username) {
            $secpasswd = ConvertTo-SecureString $Password -AsPlainText -Force
            $credentials = New-Object System.Management.Automation.PSCredential ($Username, $secpasswd)
        }

        $ErrorActionPreference = "Stop"
        foreach($item in $Server) {
            try {
                if ($Credentials) {
                    $TargetedUpdates = Get-WmiObject -Namespace root\CCM\ClientSDK -Class CCM_SoftwareUpdate -Filter ComplianceState=0 -ComputerName $item -Credential $Credentials -ErrorAction stop
                }
                else {
                    $TargetedUpdates = Get-WmiObject -Namespace root\CCM\ClientSDK -Class CCM_SoftwareUpdate -Filter ComplianceState=0 -ComputerName $item -ErrorAction stop
                }
            }
            catch {
                Write-Host "$(get-date -Format s) | [ERROR] Unable to connect to $item" -ForegroundColor Red
                Return
            }

            Write-Host "$(get-date -Format s) | Successfully connected to $item" -ForegroundColor Green
            Write-Host "$(get-date -Format s) | List available updates" -ForegroundColor Cyan
            $AvailableUpdates = @($TargetedUpdates).count
            if ($AvailableUpdates -ne 0) {
                Foreach ($kb in $TargetedUpdates) {
                    Write-Host "$(get-date -Format s) | KB$($kb.ArticleID) - $($kb.name)"
                }
            }
            else {
                Write-Host "$(get-date -Format s) | No available updates"
            }

            Write-Host "$(get-date -Format s) | Check updates status" -ForegroundColor Cyan
            if ($AvailableUpdates -ne 0) {
                Foreach ($kb in $TargetedUpdates) {
                    switch ($kb.EvaluationState) {
                        0 { $Message = "is not started" }
                        1 { $Message = "is available" }
                        2 { $Message = "is submitted" }
                        3 { $Message = "is detecting" }
                        4 { $Message = "is predownloading" }
                        5 { $Message = "is downloading" }
                        6 { $Message = "is waiting for install" }
                        7 { $Message = "is installing" }
                        8 { $Message = "needs soft reboot" }
                        9 { $Message = "needs hard reboot" }
                        10 { $Message = "is waiting for reboot" }
                        11 { $Message = "is verifying" }
                        12 { $Message = "is completed" }
                        13 { $Message = "has failed" }
                        14 { $Message = "waits for service window" }
                        15 { $Message = "waits user logon" }
                        16 { $Message = "waits user logoff" }
                        17 { $Message = "waits job user logon" }
                        18 { $Message = "waits user reconnection" }
                        19 { $Message = "wait for pending user logoff" }
                        20 { $Message = "waits for other pending update" }
                        21 { $Message = "is waiting a retry" }
                        22 { $Message = "waits for presentation mode off" }
                        23 { $Message = "waits for orchestration" }
                    }
                    Write-Host "$(get-date -Format s) | KB$($kb.ArticleID) $Message"
                }
                $PendingUpdates = @($TargetedUpdates | Where-Object {$_.EvaluationState -ne 8}).count
                $RebootPending = @($TargetedUpdates | Where-Object {$_.EvaluationState -eq 8}).count
                Write-Host "$(get-date -Format s) | Total: $AvailableUpdates - ToInstall: $PendingUpdates - RebootPending: $RebootPending"
            }
            else {
                Write-Host "$(get-date -Format s) | No pending updates"
            }
        }
    }
}