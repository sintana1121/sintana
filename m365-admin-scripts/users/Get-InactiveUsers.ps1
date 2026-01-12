<#
.SYNOPSIS
    Detect users who have not signed in for a specified period.

.DESCRIPTION
    Retrieves all users and identifies those who have not signed in for the 
    specified number of days. Useful for license reclamation and security audits.
    
    This script performs READ-ONLY operations. No modifications are made to your tenant.

.PARAMETER OutputPath
    Output CSV file path.
    Default: Desktop with timestamp (e.g., InactiveUsers_20260112.csv)

.PARAMETER InactiveDays
    Number of days without sign-in to consider a user inactive.
    Default: 90

.EXAMPLE
    .\Get-InactiveUsers.ps1
    
    Finds users inactive for 90+ days.

.EXAMPLE
    .\Get-InactiveUsers.ps1 -InactiveDays 60
    
    Finds users inactive for 60+ days.

.NOTES
    =======================================================================
    Script:       Get-InactiveUsers.ps1
    Author:       Sintana (SintanaProduction)
    Version:      1.0.0
    Created:      2026-01-12
    Updated:      2026-01-12
    GitHub:       https://github.com/sintana1121/m365-admin-scripts
    =======================================================================
    
    REQUIREMENTS:
    - PowerShell 5.1 or later
    - Microsoft Graph PowerShell SDK
    
    REQUIRED PERMISSIONS:
    - User.Read.All
    - AuditLog.Read.All
    
    CHANGE LOG:
    - 1.0.0 (2026-01-12): Initial release

.LINK
    https://github.com/sintana1121/m365-admin-scripts
#>

#Requires -Version 5.1

[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$OutputPath = "$env:USERPROFILE\Desktop\InactiveUsers_$(Get-Date -Format 'yyyyMMdd').csv",

    [Parameter()]
    [ValidateRange(1, 365)]
    [int]$InactiveDays = 90
)

#region Constants
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$SCRIPT_NAME = "Get-InactiveUsers"
$SCRIPT_VERSION = "1.0.0"
$REQUIRED_SCOPES = @("User.Read.All", "AuditLog.Read.All")
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

    Write-Log "Inactive threshold: $InactiveDays days"
    $thresholdDate = (Get-Date).AddDays(-$InactiveDays)
    Write-Log "Looking for users who haven't signed in since: $($thresholdDate.ToString('yyyy-MM-dd'))"
    Write-Host ""

    # Step 1: Connect
    Write-Log "Step 1/4: Connecting to Microsoft Graph"
    if (-not (Connect-GraphWithScopes -Scopes $REQUIRED_SCOPES)) {
        throw "Failed to establish connection"
    }

    # Step 2: Get users with sign-in activity
    Write-Log "Step 2/4: Retrieving user information with sign-in activity..."
    try {
        $users = Get-MgUser -All -Property Id, DisplayName, UserPrincipalName, AccountEnabled, Department, AssignedLicenses, SignInActivity
        Write-Log "Found $($users.Count) users" -Level Success
    } catch {
        Write-Log "Failed to retrieve users: $($_.Exception.Message)" -Level Error
        throw
    }

    # Step 3: Filter inactive users
    Write-Log "Step 3/4: Analyzing sign-in activity..."
    $report = @()

    foreach ($user in $users) {
        $lastSignIn = $user.SignInActivity.LastSignInDateTime
        
        if ($null -eq $lastSignIn) {
            $daysSinceSignIn = "Never"
            $isInactive = $true
        } else {
            $daysSinceSignIn = [math]::Round(((Get-Date) - $lastSignIn).TotalDays)
            $isInactive = $daysSinceSignIn -ge $InactiveDays
        }

        if (-not $isInactive) { continue }

        $hasLicense = $user.AssignedLicenses.Count -gt 0

        $report += [PSCustomObject]@{
            DisplayName      = $user.DisplayName
            UPN              = $user.UserPrincipalName
            AccountEnabled   = $user.AccountEnabled
            Department       = $user.Department
            HasLicense       = $hasLicense
            LastSignIn       = if ($lastSignIn) { $lastSignIn.ToString("yyyy-MM-dd HH:mm") } else { "-" }
            DaysSinceSignIn  = $daysSinceSignIn
        }
    }

    # Sort by days since sign-in (Never first, then by days descending)
    $report = $report | Sort-Object { if ($_.DaysSinceSignIn -eq "Never") { [int]::MaxValue } else { [int]$_.DaysSinceSignIn } } -Descending

    Write-Log "Found $($report.Count) inactive users" -Level Success

    # Step 4: Export
    Write-Log "Step 4/4: Exporting to CSV..."
    if ($report.Count -gt 0) {
        Export-ReportToCsv -Data $report -Path $OutputPath | Out-Null
    } else {
        Write-Log "No inactive users found" -Level Success
    }

    # Summary - @()で配列を保証
    $withLicense = @($report | Where-Object { $_.HasLicense -eq $true }).Count
    $neverSignedIn = @($report | Where-Object { $_.DaysSinceSignIn -eq "Never" }).Count
    $disabledWithLicense = @($report | Where-Object { $_.AccountEnabled -eq $false -and $_.HasLicense -eq $true }).Count

    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host " Summary" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  Inactive Users:        $(@($report).Count)"
    Write-Host "  With License:          $withLicense" -ForegroundColor $(if ($withLicense -gt 0) { "Yellow" } else { "White" })
    Write-Host "  Never Signed In:       $neverSignedIn"
    Write-Host "  Disabled w/ License:   $disabledWithLicense" -ForegroundColor $(if ($disabledWithLicense -gt 0) { "Red" } else { "White" })
    Write-Host ""
    
    if ($withLicense -gt 0) {
        Write-Host "  [!] $withLicense inactive users have licenses assigned." -ForegroundColor Yellow
        Write-Host "      Consider reviewing for potential cost savings." -ForegroundColor Yellow
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
