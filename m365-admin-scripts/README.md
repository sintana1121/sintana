# m365-admin-scripts

**「なんとなく動いている」M365環境を、数値で把握する。**

Microsoft 365 管理者のための実戦的 PowerShell スクリプト集。  
Graph PowerShell SDK を使用し、GUI では取得困難な情報を一括抽出します。

---

## Overview

中小企業の M365 環境には共通の問題がある。

- 誰がどのライセンスを持っているか、正確に把握できていない
- MFA が有効になっていないユーザーが放置されている
- 退職者のアカウントが残ったままになっている
- SharePoint のサイトが乱立し、誰も管理していない

これらは GUI で一つずつ確認するには限界がある。  
本リポジトリは、これらの情報を **1コマンドで CSV 出力** するスクリプトを提供します。

---

## Directory Structure

```
m365-admin-scripts/
├── license/          # ライセンス管理
│   └── Get-M365LicenseReport.ps1
│
├── users/            # ユーザー管理
│   └── Get-InactiveUsers.ps1
│
├── security/         # セキュリティ監査
│   └── Get-MFAStatus.ps1
│
├── requirements.md   # 実行環境
├── CONTRIBUTING.md   # 貢献ガイド
└── LICENSE           # MIT License
```

---

## Quick Start

### 1. 前提条件

```powershell
# PowerShell バージョン確認（5.1 以上）
$PSVersionTable.PSVersion

# Microsoft Graph モジュールのインストール
Install-Module Microsoft.Graph -Scope CurrentUser
```

### 2. スクリプトの取得

```powershell
git clone https://github.com/sintana1121/sintana.git
cd sintana/m365-admin-scripts
```

### 3. 実行

```powershell
# ライセンスレポートを出力
.\license\Get-M365LicenseReport.ps1

# MFA 状況を確認
.\security\Get-MFAStatus.ps1
```

初回実行時、Microsoft アカウントでの認証ダイアログが表示されます。

---

## Script Catalog

| Category | Script | Description |
|----------|--------|-------------|
| License | [Get-M365LicenseReport.ps1](./license/Get-M365LicenseReport.ps1) | 全ユーザーのライセンス割当状況をCSV出力 |
| Users | [Get-InactiveUsers.ps1](./users/Get-InactiveUsers.ps1) | 90日以上サインインのないユーザーを検出 |
| Security | [Get-MFAStatus.ps1](./security/Get-MFAStatus.ps1) | 多要素認証の設定状況を確認 |

各スクリプトは **本番環境で即座に使用可能** な品質です。

---

## Required Permissions

| Script | Required Scopes |
|--------|-----------------|
| Get-M365LicenseReport | `User.Read.All`, `Directory.Read.All` |
| Get-InactiveUsers | `User.Read.All`, `AuditLog.Read.All` |
| Get-MFAStatus | `UserAuthenticationMethod.Read.All`, `User.Read.All` |

各スクリプトは実行時に必要なスコープのみを要求します。

---

## Design Principles

本リポジトリのスクリプトは以下の原則で設計されています。

### Read-Only

すべてのスクリプトは **読み取り専用** です。  
データの変更・削除は一切行いません。本番環境で安全に実行できます。

### Self-Contained

外部ファイルや設定ファイルへの依存はありません。  
スクリプト単体で完結します。

### Defensive Coding

- `Try-Catch` による例外処理
- `CmdletBinding` によるパラメータ検証
- 詳細なエラーメッセージ

### Comment-Based Help

すべてのスクリプトに `Get-Help` 対応のドキュメントを内包。

```powershell
Get-Help .\license\Get-M365LicenseReport.ps1 -Full
```

---

## Troubleshooting

### モジュールが見つからない

```
用語 'Connect-MgGraph' は、コマンドレット...として認識されません
```

**Solution:**
```powershell
Install-Module Microsoft.Graph -Scope CurrentUser -Force
Import-Module Microsoft.Graph.Users
Import-Module Microsoft.Graph.Identity.DirectoryManagement
```

### 権限エラー

```
Insufficient privileges to complete the operation
```

**Solution:**  
グローバル管理者、または適切な Azure AD ロールを持つアカウントで再実行してください。

### 実行ポリシーエラー

```
このシステムではスクリプトの実行が無効になっている...
```

**Solution:**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

詳細は [requirements.md](./requirements.md) を参照してください。

---

## For Enterprise Use

本リポジトリのスクリプトは **単発の情報取得** に特化しています。

以下が必要な場合は、商用版をご検討ください：

- **定期実行とアラート通知** - 問題を検出したら自動通知
- **複数テナント対応** - MSP/マネージドサービス向け
- **Power Automate連携** - ワークフロー自動化
- **導入支援・カスタマイズ** - 貴社環境に合わせた設定

👉 **[Sintana Production - M365業務改善パック](https://sintana.site)**

---

## Related Resources

- [Microsoft Graph PowerShell SDK Documentation](https://docs.microsoft.com/ja-jp/powershell/microsoftgraph/)
- [Microsoft Graph permissions reference](https://docs.microsoft.com/en-us/graph/permissions-reference)

### Technical Articles

M365 管理の実務ノウハウは Qiita で公開しています。

- [M365管理センターで最初にやるべき10の設定](https://qiita.com/SintanaProduction) 
- [SharePoint のアクセス権設計で失敗しない方法](https://qiita.com/SintanaProduction)

---

## Author

**Sintana**

Microsoft 365 の設計・運用を専門とするコンサルタント。  
20年以上の IT 経験を持ち、中小企業の業務効率化を支援。

- GitHub: [@sintana1121](https://github.com/sintana1121)
- Qiita: [@SintanaProduction](https://qiita.com/SintanaProduction)
- X: [@sintana2222](https://x.com/sintana2222)
- Website: [sintana.site](https://sintana.site)

---

## License

[MIT License](./LICENSE)

---

## Disclaimer

- 本リポジトリのスクリプトは情報提供を目的としています
- 本番環境での実行前に、必ずテスト環境で動作確認を行ってください
- スクリプトの使用によって生じた損害について、作者は責任を負いません
- Microsoft Graph API の仕様変更により、動作しなくなる可能性があります
