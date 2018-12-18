
Function Invoke-BaselinesEvaluation {
    
    <#
    .SYNOPSIS
        Allows to trigger SCCM agent baselines evaluation
    .DESCRIPTION
    .LINK    
    .NOTES
    .PARAMETER Server
        Allow to specify a target computer
    .PARAMETER Usernmae
        Allow to specify an alternate user account
    .PARAMETER Password
        Allow to specify an alternate password
    .PARAMETER Baseline
        Allow to specify a specific baseline to evaluate
    .EXAMPLE
        Invoke-BaselinesEvaluation
    .EXAMPLE
        Invoke-BaselinesEvaluation -Server MyServer1
    .EXAMPLE
        get-content .\serverlist.txt | Invoke-BaselinesEvaluation -Username MyUser -Password MyPassword
    #>

    Param(
        [Parameter(Mandatory=$false,ValueFromPipeline=$true)][ValidateNotNullOrEmpty()][String]$Server,
        [Parameter(Mandatory=$false)][ValidateNotNullOrEmpty()][String]$Username,
        [Parameter(Mandatory=$false)][ValidateNotNullOrEmpty()][String]$Password,
        [Parameter(Mandatory=$false)][ValidateNotNullOrEmpty()][String]$Baseline
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
        foreach($item in $Server)
        {
            try {
                if ($Credentials) {
                    $ListOfBaselines = Get-WmiObject -ComputerName $item -Namespace root\ccm\dcm -Class SMS_DesiredConfiguration -Credential $Credentials
                    if ($Baseline) {
                        $ListOfBaselines = $ListOfBaselines | Where-Object {$_.DisplayName -eq $Baseline}
                    }
                    ForEach ($BL in $ListOfBaselines) {
                        Invoke-WmiMethod -ComputerName $item -Namespace root\CCM\dcm -Class SMS_DesiredConfiguration -Name TriggerEvaluation -ArgumentList $true,$true,$BL.Name,$BL.Version -Credential $Credentials | out-null
                    }
                }
                else {
                    $ListOfBaselines = Get-WmiObject -ComputerName $item -Namespace root\ccm\dcm -Class SMS_DesiredConfiguration
                    if ($Baseline) {
                        $ListOfBaselines = $ListOfBaselines | Where-Object {$_.DisplayName -eq $Baseline}
                    }
                    ForEach ($BL in $ListOfBaselines) {
                        Invoke-WmiMethod -ComputerName $item -Namespace root\CCM\dcm -Class SMS_DesiredConfiguration -Name TriggerEvaluation -ArgumentList $true,$true,$BL.Name,$BL.Version | out-null
                    }
                }
                Write-Host "$(get-date -Format s) | Baseline evaluation successfully triggered for $item"
            }
            catch {
                Write-Host "$(get-date -Format s) | [WARNING] Unable to trigger Baseline evaluation for $item" -ForegroundColor Yellow
            }
        }
    }    
}
