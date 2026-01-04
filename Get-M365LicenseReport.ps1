<#
.SYNOPSIS
    Microsoft 365 ライセンス割当レポートを出力します

.DESCRIPTION
    テナント内の全ユーザーのライセンス割当状況をCSVで出力します。
    Microsoft Graph PowerShell モジュールが必要です。

.PARAMETER OutputPath
    出力先CSVファイルのパス（省略時: デスクトップ）

.EXAMPLE
    .\Get-M365LicenseReport.ps1
    .\Get-M365LicenseReport.ps1 -OutputPath "C:\Reports\license.csv"

.NOTES
    作成者: シンタナ (sintana1121)
    作成日: 2026-01-04
    必要モジュール: Microsoft.Graph.Users, Microsoft.Graph.Identity.DirectoryManagement
    必要権限: User.Read.All, Directory.Read.All

.LINK
    https://sintana.site
#>

#Requires -Modules Microsoft.Graph.Users, Microsoft.Graph.Identity.DirectoryManagement

[CmdletBinding()]
param(
    [Parameter()]
    [string]$OutputPath = "$env:USERPROFILE\Desktop\M365LicenseReport_$(Get-Date -Format 'yyyyMMdd').csv"
)

#-----------------------------------------
# 1. Graph に接続
#-----------------------------------------
Write-Host "Microsoft Graph に接続しています..." -ForegroundColor Cyan

try {
    Connect-MgGraph -Scopes "User.Read.All", "Directory.Read.All" -ErrorAction Stop
    Write-Host "接続成功" -ForegroundColor Green
}
catch {
    Write-Error "接続に失敗しました: $_"
    exit 1
}

#-----------------------------------------
# 2. ユーザー情報取得
#-----------------------------------------
Write-Host "ユーザー情報を取得しています..." -ForegroundColor Cyan

$users = Get-MgUser -All -Property DisplayName, UserPrincipalName, AccountEnabled, AssignedLicenses

#-----------------------------------------
# 3. ライセンス情報を整形
#-----------------------------------------
Write-Host "ライセンス情報を整形しています..." -ForegroundColor Cyan

# SKU一覧を取得（ライセンス名変換用）
$skus = Get-MgSubscribedSku | Select-Object SkuId, SkuPartNumber

$report = foreach ($user in $users) {
    $licenseNames = foreach ($license in $user.AssignedLicenses) {
        $sku = $skus | Where-Object { $_.SkuId -eq $license.SkuId }
        $sku.SkuPartNumber
    }
    
    [PSCustomObject]@{
        DisplayName       = $user.DisplayName
        UserPrincipalName = $user.UserPrincipalName
        AccountEnabled    = $user.AccountEnabled
        Licenses          = ($licenseNames -join "; ")
        LicenseCount      = $user.AssignedLicenses.Count
    }
}

#-----------------------------------------
# 4. CSV出力
#-----------------------------------------
$report | Export-Csv -Path $OutputPath -NoTypeInformation -Encoding UTF8

Write-Host "`n完了しました！" -ForegroundColor Green
Write-Host "出力先: $OutputPath" -ForegroundColor Yellow

#-----------------------------------------
# 5. 切断
#-----------------------------------------
Disconnect-MgGraph | Out-Null
