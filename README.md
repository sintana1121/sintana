# sintana — M365 Admin Scripts & AI Automation Tools

> **M365テナント管理・Power Automate・AI業務自動化のPowerShellスクリプト集。情シス担当者・M365エンジニア向け。**

[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue)](https://github.com/PowerShell/PowerShell)
[![Microsoft Graph](https://img.shields.io/badge/Microsoft%20Graph-SDK-0078D4)](https://learn.microsoft.com/ja-jp/powershell/microsoftgraph/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green)](LICENSE)

---

## 概要

IT業界20年のM365テクニカルサポート シニアエンジニアが、**実務で繰り返し使うスクリプトを公開**しているリポジトリです。

- Graph PowerShell SDK を使ったユーザー管理自動化
- Microsoft 365 セキュリティ設定の一括適用
- ライセンス管理・幽霊アカウント検出

すべてのスクリプトは実際のM365テナント運用で検証済みです。

---

## ディレクトリ構成

```
sintana/
├── users/          # ユーザー管理（作成・無効化・ライセンス付与）
├── security/       # セキュリティ設定（MFA・条件付きアクセス）
├── license/        # ライセンス管理（棚卸し・一括付与・剥奪）
├── CONTRIBUTING.md # コントリビュートガイド
├── requirements.md # 実行環境・依存モジュール
└── README.md       # 本ファイル
```

---

## 主要スクリプト

### users/

| ファイル | 概要 |
|----------|------|
| `Disable-RetiredUser.ps1` | 退職者アカウントの無効化＋サインインセッション即時失効 |
| `Get-InactiveUsers.ps1` | 90日以上未ログインのユーザーをCSV出力（幽霊アカウント検出） |
| `Set-BulkLicense.ps1` | CSVからライセンスを一括付与・剥奪 |
| `New-UserOnboarding.ps1` | 新入社員アカウント作成＋グループ追加＋ライセンス付与の一括処理 |

### security/

| ファイル | 概要 |
|----------|------|
| `Enable-MFAForAll.ps1` | 全ユーザーのMFA強制有効化 |
| `Get-MFAStatus.ps1` | MFA登録状況の一覧出力 |
| `New-BreakGlassAccount.ps1` | 緊急アクセス（Break Glass）アカウントの作成 |

### license/

| ファイル | 概要 |
|----------|------|
| `Get-LicenseInventory.ps1` | テナント全ライセンスの使用状況サマリー出力 |
| `Remove-UnusedLicense.ps1` | 90日間未使用ライセンスの検出・剥奪候補リスト出力 |

---

## 実行環境

```powershell
# 必要モジュールのインストール
Install-Module Microsoft.Graph -Scope CurrentUser -Force
Install-Module AzureAD -Scope CurrentUser -Force  # 一部スクリプトで使用

# 接続（テナント管理者権限が必要）
Connect-MgGraph -Scopes "User.ReadWrite.All", "Directory.ReadWrite.All", "AuditLog.Read.All"
```

詳細は [requirements.md](requirements.md) を参照してください。

---

## 使い方（例）

```powershell
# 退職者を一括処理（CSVでUPNリストを渡す）
.\users\Disable-RetiredUser.ps1 -CsvPath ".\retirement_list.csv"

# 幽霊アカウントを検出してCSV出力
.\users\Get-InactiveUsers.ps1 -InactiveDays 90 -OutputPath ".\inactive_users.csv"

# ライセンス棚卸し
.\license\Get-LicenseInventory.ps1
```

---

## AI業務自動化サービス

スクリプトのカスタマイズや、Power Automate・Copilotを使った業務自動化の構築支援も行っています。

🔗 [ポートフォリオ・実績](https://sintana.site/portfolio/)
🔗 [AI業務自動化サービス（ここナラ）](https://coconala.com/services/4123087)
📺 [YouTube: Microsoft 365 実務ガイド](https://youtube.com/@m365guidejp)

---

## ライセンス

MIT License — 改変・商用利用自由。スクリプトは自己責任でご使用ください。本番環境での実行前に必ずテストテナントで動作確認してください。

---

**SiNTANA Production** | sintana.site
