
Function Start-CMCheck {

    <#
    .SYNOPSIS
        Allows to perform SCCM agent checks
    .DESCRIPTION
    .LINK    
    .NOTES
    .PARAMETER AutoRepair
        Try to perform auto-remediation if possible when an issue has been found
    .PARAMETER Server
        Allow to specify a target computer --- WINRM MUST BE CONFIGURED
    .PARAMETER Usernmae
        Allow to specify an alternate user account
    .PARAMETER Password
        Allow to specify an alternate password
    .EXAMPLE
        Start-CMCheck -AutoRepair
    .EXAMPLE
        Start-CMCheck -Server MyServer1
    .EXAMPLE
        get-content .\serverlist.txt | Start-CMCheck -Username MyUser -Password MyPassword
    #>

    Param(
        [Parameter(Mandatory=$false)][Switch]$AutoRepair,
        [Parameter(Mandatory=$false,ValueFromPipeline=$true)][ValidateNotNullOrEmpty()][String]$Server,
        [Parameter(Mandatory=$false)][ValidateNotNullOrEmpty()][String]$Username,
        [Parameter(Mandatory=$false)][ValidateNotNullOrEmpty()][String]$Password
    )

    Process {
        if ($Username) {
            $secpasswd = ConvertTo-SecureString $Password -AsPlainText -Force
            $credentials = New-Object System.Management.Automation.PSCredential ($Username, $secpasswd)
        }

        $PluginsPath = "$($PSScriptRoot)\..\Private"
        $CheckPoints = Get-ChildItem $PluginsPath -File | Sort-Object Name

        #Create script block to run
        $ScriptBlock = {Param([Parameter(Mandatory=$true)]$Configuration,[Parameter(Mandatory=$false)]$AutoRepair)}
        ForEach ($ScriptFile in $Checkpoints) {
            $Control = $ScriptFile.BaseName.split('.')[1]
            $ScriptBlockToAdd = {
                $result = Invoke-Expression "Check-###"
                if ($AutoRepair -and ($result -eq "NotCompliant")) {
                    Invoke-Expression "Repair-###"
                }
            }
            $ScriptBlock = [ScriptBlock]::Create($ScriptBlock.ToString()+$ScriptBlockToAdd.ToString().replace('###',$Control))
        }

        if ([string]::IsNullOrEmpty($Server)) {
            #Load functions locally
            ForEach ($ScriptFile in $Checkpoints) {
                . $ScriptFile.FullName
            }

            #Perform controls locally
            Invoke-Command -ScriptBlock $ScriptBlock -ArgumentList $Global:Configuration,$AutoRepair.IsPresent
        }
        else {
            $ErrorActionPreference = "Stop"
            foreach($item in $Server) {
                #Create remote session
                try {
                    if ($Credentials) {
                        $Session = New-PSSession -ComputerName $item -Credential $Credentials -ErrorAction Stop
                    }
                    else {
                        $Session = New-PSSession -ComputerName $item -ErrorAction Stop
                    }
                }
                catch {
                    Write-Host "$(get-date -Format s) | [ERROR] Unable to connect to $item" -ForegroundColor Red
                    Return
                }

                Write-Host "$(get-date -Format s) | Successfully connected to $item" -ForegroundColor Green

                #Load functions remotely
                ForEach ($ScriptFile in $Checkpoints) {
                    Invoke-Command -Session $Session -FilePath $ScriptFile.FullName
                }

                #Perform controls remotely
                Invoke-Command -Session $Session -ScriptBlock $ScriptBlock -ArgumentList $Global:Configuration,$AutoRepair.IsPresent

                #Exit remote session
                Remove-PSSession -Session $Session
            }
            Write-Host "$(get-date -Format s) | All Checks completed" -ForegroundColor Cyan
        }
    }
}
