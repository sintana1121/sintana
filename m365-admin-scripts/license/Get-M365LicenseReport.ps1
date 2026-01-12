<#
.SYNOPSIS
    Export Microsoft 365 license assignment status for all users.

.DESCRIPTION
    Retrieves all users in your Microsoft 365 tenant and exports their license 
    assignment status to a CSV file. License SKU names are dynamically retrieved 
    from your tenant, ensuring accurate naming regardless of your subscription type.
    
    This script performs READ-ONLY operations. No modifications are made to your tenant.

.PARAMETER OutputPath
    Output CSV file path.
    Default: Desktop with timestamp (e.g., M365LicenseReport_20260112.csv)

.EXAMPLE
    .\Get-M365LicenseReport.ps1
    
    Runs with default parameters, outputs to Desktop.

.EXAMPLE
    .\Get-M365LicenseReport.ps1 -OutputPath "C:\Reports\license.csv"
    
    Specifies custom output path.

.NOTES
    =======================================================================
    Script:       Get-M365LicenseReport.ps1
    Author:       Sintana (SintanaProduction)
    Version:      2.0.0
    Created:      2026-01-01
    Updated:      2026-01-12
    GitHub:       https://github.com/sintana1121/m365-admin-scripts
    =======================================================================
    
    REQUIREMENTS:
    - PowerShell 5.1 or later
    - Microsoft Graph PowerShell SDK
    - Microsoft 365 tenant with appropriate permissions
    
    REQUIRED PERMISSIONS:
    - User.Read.All
    - Directory.Read.All
    
    CHANGE LOG:
    - 2.0.0 (2026-01-12): Refactored with standardized template, improved error handling
    - 1.0.0 (2026-01-01): Initial release

.LINK
    https://github.com/sintana1121/m365-admin-scripts

.LINK
    https://docs.microsoft.com/en-us/graph/api/subscribedsku-list
#>

#Requires -Version 5.1

[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(
        Position = 0,
        HelpMessage = "Output CSV file path"
    )]
    [ValidateNotNullOrEmpty()]
    [string]$OutputPath = "$env:USERPROFILE\Desktop\M365LicenseReport_$(Get-Date -Format 'yyyyMMdd').csv"
)

#region Constants
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$SCRIPT_NAME = "Get-M365LicenseReport"
$SCRIPT_VERSION = "2.0.0"
$REQUIRED_SCOPES = @("User.Read.All", "Directory.Read.All")
#endregion Constants

#region Functions
function Write-Log {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Message,

        [Parameter()]
        [ValidateSet('Info', 'Warning', 'Error', 'Success')]
        [string]$Level = 'Info'
    )

    $timestamp = Get-Date -Format "HH:mm:ss"
    $prefix = switch ($Level) {
        'Info'    { "[INFO]   " }
        'Warning' { "[WARN]   " }
        'Error'   { "[ERROR]  " }
        'Success' { "[OK]     " }
    }

    $color = switch ($Level) {
        'Info'    { 'White' }
        'Warning' { 'Yellow' }
        'Error'   { 'Red' }
        'Success' { 'Green' }
    }

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
    param(
        [Parameter(Mandatory)]
        [string[]]$Scopes
    )

    Write-Log "Connecting to Microsoft Graph..."
    
    try {
        $context = Get-MgContext -ErrorAction SilentlyContinue
        
        if ($null -eq $context) {
            Connect-MgGraph -Scopes $Scopes -NoWelcome
        }
        else {
            $missingScopes = $Scopes | Where-Object { $_ -notin $context.Scopes }
            if ($missingScopes) {
                Write-Log "Reconnecting with additional scopes: $($missingScopes -join ', ')" -Level Warning
                Disconnect-MgGraph -ErrorAction SilentlyContinue | Out-Null
                Connect-MgGraph -Scopes $Scopes -NoWelcome
            }
        }
        
        Write-Log "Connected successfully" -Level Success
        return $true
    }
    catch {
        Write-Log "Failed to connect: $($_.Exception.Message)" -Level Error
        return $false
    }
}

function Export-ReportToCsv {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [object[]]$Data,

        [Parameter(Mandatory)]
        [string]$Path
    )

    try {
        $directory = Split-Path -Path $Path -Parent
        if ($directory -and -not (Test-Path -Path $directory)) {
            New-Item -ItemType Directory -Path $directory -Force | Out-Null
        }

        $Data | Export-Csv -Path $Path -NoTypeInformation -Encoding UTF8
        Write-Log "Exported to: $Path" -Level Success
        return $true
    }
    catch {
        Write-Log "Failed to export: $($_.Exception.Message)" -Level Error
        return $false
    }
}
#endregion Functions

#region Main
function Main {
    [CmdletBinding()]
    param()

    Show-Banner

    # Step 1: Connect to Microsoft Graph
    Write-Log "Step 1/5: Connecting to Microsoft Graph"
    if (-not (Connect-GraphWithScopes -Scopes $REQUIRED_SCOPES)) {
        throw "Failed to establish connection to Microsoft Graph"
    }

    # Step 2: Get license SKUs from tenant
    Write-Log "Step 2/5: Retrieving license information from tenant..."
    
    try {
        $skus = Get-MgSubscribedSku
        $licenseNames = @{}
        foreach ($sku in $skus) {
            $licenseNames[$sku.SkuId] = $sku.SkuPartNumber
        }
        Write-Log "Found $($skus.Count) license types" -Level Success
    }
    catch {
        Write-Log "Failed to retrieve license SKUs: $($_.Exception.Message)" -Level Error
        throw
    }

    # Step 3: Get all users
    Write-Log "Step 3/5: Retrieving user information..."
    
    try {
        $users = Get-MgUser -All -Property DisplayName, UserPrincipalName, AssignedLicenses, AccountEnabled, Department, JobTitle
        Write-Log "Found $($users.Count) users" -Level Success
    }
    catch {
        Write-Log "Failed to retrieve users: $($_.Exception.Message)" -Level Error
        throw
    }

    # Step 4: Create report
    Write-Log "Step 4/5: Creating report..."
    
    $report = @()
    foreach ($user in $users) {
        $licenseList = @()
        foreach ($license in $user.AssignedLicenses) {
            $skuId = $license.SkuId
            if ($licenseNames.ContainsKey($skuId)) {
                $licenseList += $licenseNames[$skuId]
            }
            else {
                $licenseList += $skuId
            }
        }

        $report += [PSCustomObject]@{
            DisplayName  = $user.DisplayName
            UPN          = $user.UserPrincipalName
            Enabled      = $user.AccountEnabled
            Department   = $user.Department
            JobTitle     = $user.JobTitle
            LicenseCount = $user.AssignedLicenses.Count
            Licenses     = ($licenseList -join "; ")
        }
    }

    Write-Log "Report created with $($report.Count) records" -Level Success

    # Step 5: Export to CSV
    Write-Log "Step 5/5: Exporting to CSV..."
    
    if ($report.Count -eq 0) {
        Write-Log "No data to export" -Level Warning
    }
    else {
        Export-ReportToCsv -Data $report -Path $OutputPath | Out-Null
    }

    # Summary
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host " Summary" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  Total Users:      $(@($users).Count)"
    Write-Host "  With License:     $(@($report | Where-Object { $_.LicenseCount -gt 0 }).Count)"
    Write-Host "  Without License:  $(@($report | Where-Object { $_.LicenseCount -eq 0 }).Count)"
    Write-Host "  Enabled:          $(@($report | Where-Object { $_.Enabled -eq $true }).Count)"
    Write-Host "  Disabled:         $(@($report | Where-Object { $_.Enabled -eq $false }).Count)"
    Write-Host ""
    Write-Host "  License Types in Tenant:"
    foreach ($sku in $skus) {
        Write-Host "    - $($sku.SkuPartNumber): $($sku.ConsumedUnits) / $($sku.PrepaidUnits.Enabled)"
    }
    Write-Host ""
    Write-Host "  Output: $OutputPath"
    Write-Host ""
}

# Execute main function with error handling
try {
    Main
}
catch {
    Write-Log "Script failed: $($_.Exception.Message)" -Level Error
    Write-Log "Stack trace: $($_.ScriptStackTrace)" -Level Error
    exit 1
}
finally {
    if (Get-MgContext -ErrorAction SilentlyContinue) {
        Disconnect-MgGraph -ErrorAction SilentlyContinue | Out-Null
    }
}
#endregion Main
