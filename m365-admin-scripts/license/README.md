# Get-M365LicenseReport.ps1

Microsoft 365 のライセンス割当状況をCSVで出力します。

## スクリーンショット

![実行結果](screenshot.png)

## 前提条件

- Windows PowerShell 5.1 または PowerShell 7.x
- Microsoft Graph PowerShell モジュール
- 必要な権限: User.Read.All, Directory.Read.All

## モジュールのインストール
```powershell
Install-Module Microsoft.Graph -Scope CurrentUser
```

## 使い方
```powershell
# 基本実行（デスクトップに出力）
.\Get-M365LicenseReport.ps1

# 出力先を指定
.\Get-M365LicenseReport.ps1 -OutputPath "C:\Reports\license.csv"
```

## 出力例

| DisplayName | UserPrincipalName | AccountEnabled | Licenses | LicenseCount |
|-------------|-------------------|----------------|----------|--------------|
| 田中太郎 | tanaka@contoso.com | True | ENTERPRISEPACK | 1 |
| 鈴木花子 | suzuki@contoso.com | True | ENTERPRISEPACK; POWER_BI_PRO | 2 |

## 注意事項

- 初回実行時にブラウザ認証が必要です
- 大規模テナント（1万ユーザー以上）は時間がかかる場合があります

## ライセンス

MIT License

## 関連リンク

- [詳細な解説記事（Qiita）](リンク)
- [M365業務改革テンプレート](https://sintana.site)
