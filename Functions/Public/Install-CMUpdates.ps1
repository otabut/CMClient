Function Install-CMUpdates {
    
    <#
    .SYNOPSIS
        Allows to trigger install of available software updates on SCCM agent
    .DESCRIPTION
    .LINK    
    .NOTES
    .PARAMETER Server
        Allow to specify a target computer
    .PARAMETER Usernmae
        Allow to specify an alternate user account
    .PARAMETER Password
        Allow to specify an alternate password
    .PARAMETER ArticleID
        Allow to specify a comma separated list of KB to install
    .EXAMPLE
        Invoke-CMUpdates
    .EXAMPLE
        Invoke-CMUpdates -Server MyServer1
    .EXAMPLE
        get-content .\serverlist.txt | Invoke-CMUpdates -Username MyUser -Password MyPassword
    #>
    
    Param(
        [Parameter(Mandatory=$false,ValueFromPipeline=$true)][ValidateNotNullOrEmpty()][String]$Server,
        [Parameter(Mandatory=$false)][ValidateNotNullOrEmpty()][String]$Username,
        [Parameter(Mandatory=$false)][ValidateNotNullOrEmpty()][String]$Password,
        [Parameter(Mandatory=$false)][ValidateNotNullOrEmpty()][String]$ArticleID
    )

    Process {
        if ([string]::IsNullOrEmpty($Server)) {
            $Server = $env:COMPUTERNAME
        }

        if ($Username) {
            $secpasswd = ConvertTo-SecureString $Password -AsPlainText -Force
            $credentials = New-Object System.Management.Automation.PSCredential ($Username, $secpasswd)
        }

        $ErrorActionPreference = "Stop"
        foreach($item in $Server) {

            #Connect and retrieve available Software Updates
            try {
                if ($Credentials) {
                    $TargetedUpdates = Get-WmiObject -Namespace root\CCM\ClientSDK -Class CCM_SoftwareUpdate -Filter ComplianceState=0 -ComputerName $item -Credential $Credentials
                }
                else {
                    $TargetedUpdates = Get-WmiObject -Namespace root\CCM\ClientSDK -Class CCM_SoftwareUpdate -Filter ComplianceState=0 -ComputerName $item
                }
                Write-Host "$(get-date -Format s) | Successfully connected to $item" -ForegroundColor Green
                if ($ArticleID) {
                    $TargetedUpdates = $TargetedUpdates | Where-Object {$ArticleID -match $_.ArticleID}
                }
                $MissingUpdatesReformatted = @($TargetedUpdates | ForEach-Object {if ($_.ComplianceState -eq 0) {[WMI]$_.__PATH}})
            }
            catch {
                Write-Host "$(get-date -Format s) | [ERROR] Unable to connect to $item" -ForegroundColor Red
                Return
            }
            
            #Check if reboot pending
            Write-Host "$(get-date -Format s) | Check if system reboot is pending" -ForegroundColor Cyan
            try {
                if ($Credentials) {                    
                    $CCMClientSDK = Invoke-WmiMethod -Class CCM_ClientUtilities -Name DetermineIfRebootPending -NameSpace root\ccm\ClientSDK -ComputerName $item -Credential $Credentials
                }
                else {
                    $CCMClientSDK = Invoke-WmiMethod -Class CCM_ClientUtilities -Name DetermineIfRebootPending -NameSpace root\ccm\ClientSDK -ComputerName $item
                }
            }
            catch {
                return
            }
            If ($CCMClientSDK.IsHardRebootPending -or $CCMClientSDK.RebootPending)
            {
                Write-Host "$(get-date -Format s) | [WARNING] Perform a system restart before installing updates" -ForegroundColor Yellow
                return
            }
            else {
                Write-Host "$(get-date -Format s) | No pending restart"
            }
            
            #Trigger Software Updates install
            Write-Host "$(get-date -Format s) | Install updates" -ForegroundColor Cyan
            try {
                if ($Credentials) {                  
                    Invoke-WmiMethod -Class CCM_SoftwareUpdatesManager -Name InstallUpdates -ArgumentList (, $MissingUpdatesReformatted) -Namespace root\ccm\clientsdk -ComputerName $item -Credential $Credentials | Out-Null
                }
                else {
                    Invoke-WmiMethod -Class CCM_SoftwareUpdatesManager -Name InstallUpdates -ArgumentList (, $MissingUpdatesReformatted) -Namespace root\ccm\clientsdk -ComputerName $item | Out-Null
                }
                Write-Host "$(get-date -Format s) | Install has been successfully triggered, please wait for completion and check if a system restart is needed"
            }
            catch {
                Write-Host "$(get-date -Format s) | [ERROR] Unable to install updates" -ForegroundColor Red
            }
        }
    }
}