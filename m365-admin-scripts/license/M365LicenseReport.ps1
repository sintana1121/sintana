<#
.SYNOPSIS
    Microsoft 365 License Report

.DESCRIPTION
    Export all users license assignment status to CSV.
    License names are dynamically retrieved from your tenant.

.PARAMETER OutputPath
    Output CSV file path (default: Desktop)

.EXAMPLE
    .\Get-M365LicenseReport.ps1

.NOTES
    Author: SintanaProduction
    GitHub: https://github.com/sintana1121
#>

[CmdletBinding()]
param(
    [Parameter()]
    [string]$OutputPath = "$env:USERPROFILE\Desktop\M365LicenseReport_$(Get-Date -Format 'yyyyMMdd').csv"
)

try {
    Write-Host "========================================"
    Write-Host " M365 License Report"
    Write-Host "========================================"
    Write-Host ""

    # 1. Connect to Microsoft Graph
    Write-Host "[1/5] Connecting to Microsoft Graph..."
    Connect-MgGraph -Scopes "User.Read.All", "Directory.Read.All" -NoWelcome
    Write-Host "      Connected"
    Write-Host ""

    # 2. Get all SKUs from tenant (dynamic license name mapping)
    Write-Host "[2/5] Getting license information from tenant..."
    $skus = Get-MgSubscribedSku
    $LicenseNames = @{}
    foreach ($sku in $skus) {
        $LicenseNames[$sku.SkuId] = $sku.SkuPartNumber
    }
    Write-Host "      Found $($skus.Count) license types"
    Write-Host ""

    # 3. Get all users
    Write-Host "[3/5] Getting user information..."
    $users = Get-MgUser -All -Property DisplayName, UserPrincipalName, AssignedLicenses, AccountEnabled, Department, JobTitle
    Write-Host "      Found $($users.Count) users"
    Write-Host ""

    # 4. Create report
    Write-Host "[4/5] Creating report..."
    $report = @()

    foreach ($user in $users) {
        $licenseList = @()
        foreach ($license in $user.AssignedLicenses) {
            $skuId = $license.SkuId
            if ($LicenseNames.ContainsKey($skuId)) {
                $licenseList += $LicenseNames[$skuId]
            } else {
                $licenseList += $skuId
            }
        }

        $report += [PSCustomObject]@{
            DisplayName    = $user.DisplayName
            UPN            = $user.UserPrincipalName
            Enabled        = $user.AccountEnabled
            Department     = $user.Department
            JobTitle       = $user.JobTitle
            LicenseCount   = $user.AssignedLicenses.Count
            Licenses       = ($licenseList -join "; ")
        }
    }

    Write-Host "      Done"
    Write-Host ""

    # 5. Export to CSV
    Write-Host "[5/5] Exporting to CSV..."
    $report | Export-Csv -Path $OutputPath -NoTypeInformation -Encoding UTF8
    Write-Host "      Output: $OutputPath"
    Write-Host ""

    # Summary
    Write-Host "========================================"
    Write-Host " Summary"
    Write-Host "========================================"
    Write-Host "  Total Users:      $($users.Count)"
    Write-Host "  With License:     $(($report | Where-Object { $_.LicenseCount -gt 0 }).Count)"
    Write-Host "  Without License:  $(($report | Where-Object { $_.LicenseCount -eq 0 }).Count)"
    Write-Host "  Enabled:          $(($report | Where-Object { $_.Enabled -eq $true }).Count)"
    Write-Host "  Disabled:         $(($report | Where-Object { $_.Enabled -eq $false }).Count)"
    Write-Host ""
    Write-Host "  License Types in Tenant:"
    foreach ($sku in $skus) {
        Write-Host "    - $($sku.SkuPartNumber): $($sku.ConsumedUnits) / $($sku.PrepaidUnits.Enabled)"
    }
    Write-Host ""
    Write-Host "Output: $OutputPath"
    Write-Host ""

} catch {
    Write-Host "Error: $_" -ForegroundColor Red
} finally {
    Disconnect-MgGraph -ErrorAction SilentlyContinue | Out-Null
}
