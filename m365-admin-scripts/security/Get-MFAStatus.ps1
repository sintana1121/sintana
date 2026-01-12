<#
.SYNOPSIS
    Export Multi-Factor Authentication (MFA) status for all users.

.DESCRIPTION
    Retrieves all users in your Microsoft 365 tenant and exports their MFA 
    configuration status, including registered authentication methods.
    
    This script performs READ-ONLY operations. No modifications are made to your tenant.

.PARAMETER OutputPath
    Output CSV file path.
    Default: Desktop with timestamp (e.g., MFAStatus_20260112.csv)

.PARAMETER EnabledOnly
    If specified, only exports users with MFA enabled.

.EXAMPLE
    .\Get-MFAStatus.ps1
    
    Exports MFA status for all users to Desktop.

.EXAMPLE
    .\Get-MFAStatus.ps1 -OutputPath "C:\SecurityAudit\mfa.csv"
    
    Specifies custom output path.

.NOTES
    =======================================================================
    Script:       Get-MFAStatus.ps1
    Author:       Sintana (SintanaProduction)
    Version:      1.0.0
    Created:      2026-01-12
    Updated:      2026-01-12
    GitHub:       https://github.com/sintana1121/m365-admin-scripts
    =======================================================================
    
    REQUIREMENTS:
    - PowerShell 5.1 or later
    - Microsoft Graph PowerShell SDK
    - Microsoft 365 tenant with appropriate permissions
    
    REQUIRED PERMISSIONS:
    - UserAuthenticationMethod.Read.All
    - User.Read.All
    
    CHANGE LOG:
    - 1.0.0 (2026-01-12): Initial release

.LINK
    https://github.com/sintana1121/m365-admin-scripts
#>

#Requires -Version 5.1

[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Position = 0, HelpMessage = "Output CSV file path")]
    [ValidateNotNullOrEmpty()]
    [string]$OutputPath = "$env:USERPROFILE\Desktop\MFAStatus_$(Get-Date -Format 'yyyyMMdd').csv",

    [Parameter(HelpMessage = "Only export users with MFA enabled")]
    [switch]$EnabledOnly
)

#region Constants
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$SCRIPT_NAME = "Get-MFAStatus"
$SCRIPT_VERSION = "1.0.0"
$REQUIRED_SCOPES = @("UserAuthenticationMethod.Read.All", "User.Read.All")
#endregion Constants

#region Functions
function Write-Log {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Message,
        [Parameter()][ValidateSet('Info', 'Warning', 'Error', 'Success')][string]$Level = 'Info'
    )
    $timestamp = Get-Date -Format "HH:mm:ss"
    $prefix = switch ($Level) { 'Info' { "[INFO]   " } 'Warning' { "[WARN]   " } 'Error' { "[ERROR]  " } 'Success' { "[OK]     " } }
    $color = switch ($Level) { 'Info' { 'White' } 'Warning' { 'Yellow' } 'Error' { 'Red' } 'Success' { 'Green' } }
    Write-Host "$timestamp $prefix$Message" -ForegroundColor $color
}

function Show-Banner {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host " $SCRIPT_NAME v$SCRIPT_VERSION" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
}

function Connect-GraphWithScopes {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string[]]$Scopes)
    
    Write-Log "Connecting to Microsoft Graph..."
    try {
        $context = Get-MgContext -ErrorAction SilentlyContinue
        if ($null -eq $context) {
            Connect-MgGraph -Scopes $Scopes -NoWelcome
        } else {
            $missingScopes = $Scopes | Where-Object { $_ -notin $context.Scopes }
            if ($missingScopes) {
                Disconnect-MgGraph -ErrorAction SilentlyContinue | Out-Null
                Connect-MgGraph -Scopes $Scopes -NoWelcome
            }
        }
        Write-Log "Connected successfully" -Level Success
        return $true
    } catch {
        Write-Log "Failed to connect: $($_.Exception.Message)" -Level Error
        return $false
    }
}

function Export-ReportToCsv {
    [CmdletBinding()]
    param([Parameter(Mandatory)][object[]]$Data, [Parameter(Mandatory)][string]$Path)
    
    try {
        $directory = Split-Path -Path $Path -Parent
        if ($directory -and -not (Test-Path -Path $directory)) {
            New-Item -ItemType Directory -Path $directory -Force | Out-Null
        }
        $Data | Export-Csv -Path $Path -NoTypeInformation -Encoding UTF8
        Write-Log "Exported to: $Path" -Level Success
        return $true
    } catch {
        Write-Log "Failed to export: $($_.Exception.Message)" -Level Error
        return $false
    }
}
#endregion Functions

#region Main
function Main {
    Show-Banner

    # Step 1: Connect
    Write-Log "Step 1/4: Connecting to Microsoft Graph"
    if (-not (Connect-GraphWithScopes -Scopes $REQUIRED_SCOPES)) {
        throw "Failed to establish connection"
    }

    # Step 2: Get users
    Write-Log "Step 2/4: Retrieving user information..."
    try {
        $users = Get-MgUser -All -Property Id, DisplayName, UserPrincipalName, AccountEnabled, Department
        Write-Log "Found $($users.Count) users" -Level Success
    } catch {
        Write-Log "Failed to retrieve users: $($_.Exception.Message)" -Level Error
        throw
    }

    # Step 3: Get MFA status
    Write-Log "Step 3/4: Retrieving MFA status (this may take a while)..."
    $report = @()
    $counter = 0
    $total = $users.Count

    foreach ($user in $users) {
        $counter++
        if ($counter % 10 -eq 0) {
            Write-Progress -Activity "Checking MFA Status" -Status "$counter of $total" -PercentComplete (($counter / $total) * 100)
        }

        try {
            $methods = Get-MgUserAuthenticationMethod -UserId $user.Id -ErrorAction Stop
            $methodList = @()
            $hasStrongAuth = $false

            foreach ($method in $methods) {
                $methodType = $method.AdditionalProperties["@odata.type"]
                switch ($methodType) {
                    "#microsoft.graph.microsoftAuthenticatorAuthenticationMethod" { $methodList += "Authenticator"; $hasStrongAuth = $true }
                    "#microsoft.graph.phoneAuthenticationMethod" { $methodList += "Phone"; $hasStrongAuth = $true }
                    "#microsoft.graph.fido2AuthenticationMethod" { $methodList += "FIDO2"; $hasStrongAuth = $true }
                    "#microsoft.graph.softwareOathAuthenticationMethod" { $methodList += "TOTP"; $hasStrongAuth = $true }
                    "#microsoft.graph.emailAuthenticationMethod" { $methodList += "Email" }
                    "#microsoft.graph.passwordAuthenticationMethod" { $methodList += "Password" }
                }
            }

            $mfaStatus = if ($hasStrongAuth) { "Enabled" } else { "Disabled" }
            $defaultMethod = if ($methodList.Count -gt 0) { $methodList[0] } else { "-" }
        } catch {
            $mfaStatus = "Error"
            $methodList = @()
            $defaultMethod = "-"
        }

        if ($EnabledOnly -and $mfaStatus -ne "Enabled") { continue }

        $report += [PSCustomObject]@{
            DisplayName    = $user.DisplayName
            UPN            = $user.UserPrincipalName
            AccountEnabled = $user.AccountEnabled
            Department     = $user.Department
            MFAStatus      = $mfaStatus
            DefaultMethod  = $defaultMethod
            Methods        = ($methodList -join "; ")
        }
    }

    Write-Progress -Activity "Checking MFA Status" -Completed
    Write-Log "Report created with $($report.Count) records" -Level Success

    # Step 4: Export
    Write-Log "Step 4/4: Exporting to CSV..."
    if ($report.Count -gt 0) {
        Export-ReportToCsv -Data $report -Path $OutputPath | Out-Null
    } else {
        Write-Log "No data to export" -Level Warning
    }

    # Summary
    $enabledCount = @($report | Where-Object { $_.MFAStatus -eq "Enabled" }).Count
    $disabledCount = @($report | Where-Object { $_.MFAStatus -eq "Disabled" }).Count

    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host " Summary" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  Total Users:    $(@($report).Count)"
    Write-Host "  MFA Enabled:    $enabledCount" -ForegroundColor Green
    Write-Host "  MFA Disabled:   $disabledCount" -ForegroundColor $(if ($disabledCount -gt 0) { "Red" } else { "White" })
    if ($disabledCount -gt 0) {
        Write-Host "  [!] WARNING: $disabledCount users do not have MFA enabled!" -ForegroundColor Red
    }
    Write-Host ""
    Write-Host "  Output: $OutputPath"
    Write-Host ""
}

try { Main }
catch {
    Write-Log "Script failed: $($_.Exception.Message)" -Level Error
    exit 1
}
finally {
    if (Get-MgContext -ErrorAction SilentlyContinue) {
        Disconnect-MgGraph -ErrorAction SilentlyContinue | Out-Null
    }
}
#endregion Main
