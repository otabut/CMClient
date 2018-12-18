
Function Invoke-HardwareInventory {

    <#
    .SYNOPSIS
        Allows to trigger SCCM agent hardware inventory
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
        Invoke-HardwareInventory
    .EXAMPLE
        Invoke-HardwareInventory -Server MyServer1
    .EXAMPLE
        get-content .\serverlist.txt | Invoke-HardwareInventory -Username MyUser -Password MyPassword
    #>

    Param(
        [Parameter(Mandatory=$false,ValueFromPipeline=$true)][ValidateNotNullOrEmpty()][String]$Server,
        [Parameter(Mandatory=$false)][ValidateNotNullOrEmpty()][String]$Username,
        [Parameter(Mandatory=$false)][ValidateNotNullOrEmpty()][String]$Password
    )

    process {

        $_action = "{00000000-0000-0000-0000-000000000001}"  # HardwareInv
        #$_action = "{00000000-0000-0000-0000-000000000002}"  # SoftwareInv
        #$_action = "{00000000-0000-0000-0000-000000000113}"  # UpdateScan
        #$_action = "{00000000-0000-0000-0000-000000000021}"  # MachinePol
        #$_action = "{00000000-0000-0000-0000-000000000027}"  # UserPolicy
        #$_action = "{00000000-0000-0000-0000-000000000010}"  # FileCollect

        if ([string]::IsNullOrEmpty($Server)) {
            $Server = $env:COMPUTERNAME
        }

        if ($Username) {
            $secpasswd = ConvertTo-SecureString $Password -AsPlainText -Force
            $credentials = New-Object System.Management.Automation.PSCredential ($Username, $secpasswd)
        }

        $ErrorActionPreference = "Stop"
        foreach($item in $Server)
        {
            try {
                if ($Credentials) {
                    Invoke-WmiMethod -ComputerName $item -Namespace root\CCM -Class SMS_Client -Name TriggerSchedule -ArgumentList "$_action" -Credential $Credentials | out-null
                }
                else {
                    Invoke-WmiMethod -ComputerName $item -Namespace root\CCM -Class SMS_Client -Name TriggerSchedule -ArgumentList "$_action" | out-null
                }
                Write-Host "$(get-date -Format s) | Hardware inventory successfully triggered for $item"
            }
            catch {
                Write-Host "$(get-date -Format s) | [WARNING] Unable to trigger Hardware inventory for $item" -ForegroundColor Yellow
            }
        }
    }    
}
