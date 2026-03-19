# sintana — M365 Admin Scripts

> **Microsoft 365テナント管理の実務で使えるPowerShellスクリプト集。情シス担当者・M365エンジニア向け。**

[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue)](https://github.com/PowerShell/PowerShell)
[![Microsoft Graph](https://img.shields.io/badge/Microsoft%20Graph-SDK-0078D4)](https://learn.microsoft.com/ja-jp/powershell/microsoftgraph/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green)](LICENSE)

---

## 収録スクリプト

### m365-admin-scripts/users/

| ファイル | 概要 |
|----------|------|
| `Get-InactiveUsers.ps1` | 指定日数以上サインインしていないユーザーを検出してCSV出力（幽霊アカウント棚卸し） |

### m365-admin-scripts/security/

| ファイル | 概要 |
|----------|------|
| `Get-MFAStatus.ps1` | 全ユーザーのMFA登録状況を一覧出力（未設定者の特定・監査用） |

### m365-admin-scripts/license/

| ファイル | 概要 |
|----------|------|
| `Get-M365LicenseReport.ps1` | テナント全ライセンスの使用状況レポートを出力（過剰購入・未使用の特定） |

---

## ディレクトリ構成

```
sintana/
├── README.md
└── m365-admin-scripts/
    ├── CONTRIBUTING.md
    ├── requirements.md
    ├── users/
    │   ├── Get-InactiveUsers.ps1
    │   └── README.md
    ├── security/
    │   ├── Get-MFAStatus.ps1
    │   └── README.md
    └── license/
        ├── Get-M365LicenseReport.ps1
        └── README.md
```

---

## 実行環境

```powershell
# 必要モジュールのインストール
Install-Module Microsoft.Graph -Scope CurrentUser -Force

# 接続（テナント管理者権限が必要）
Connect-MgGraph -Scopes "User.ReadWrite.All", "Directory.ReadWrite.All", "AuditLog.Read.All"
```

詳細は [requirements.md](m365-admin-scripts/requirements.md) を参照してください。

---

## 使い方（例）

```powershell
# 90日以上サインインしていないユーザーを検出
.\m365-admin-scripts\users\Get-InactiveUsers.ps1 -InactiveDays 90 -OutputPath ".\inactive_users.csv"

# MFA登録状況を一覧出力
.\m365-admin-scripts\security\Get-MFAStatus.ps1

# ライセンス使用状況レポートを出力
.\m365-admin-scripts\license\Get-M365LicenseReport.ps1
```

---

## 関連記事

📝 [Graph PowerShellでM365ユーザー管理を自動化する実践ガイド（Qiita）](https://qiita.com/SintanaProduction)

---

## ライセンス

MIT License — 改変・商用利用自由。本番環境での実行前に必ずテストテナントで動作確認してください。

---

**SiNTANA Production** | [sintana.site/portfolio/](https://sintana.site/portfolio/) | [YouTube: M365実務ガイド](https://youtube.com/@m365guidejp)
