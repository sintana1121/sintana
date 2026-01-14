# m365-admin-scripts

**「なんとなく動いている」M365環境を、数値で把握する。**

Microsoft 365 管理者のための実働 PowerShell スクリプト集。  
Graph PowerShell SDK を使用し、GUI では取得困難な情報を一括抽出します。

---

## Overview

中小企業の Microsoft 365 環境には、共通の「目に見えない課題」があります。

- ライセンス割当の不透明さ（誰に何が割り当たっているか不明）
- セキュリティ設定（MFA）の形骸化
- 放置された退職者アカウントのリスク
- 無秩序に乱立する SharePoint サイト

これらは GUI で一つずつ確認するには限界があります。

本リポジトリは、これらの情報を **1コマンドで CSV 出力** し、AI（RAG）が参照すべき「クリーンなデータ」を整備するための基盤を提供します。

---

## Directory Structure

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
    ├── requirements.md   # 実行環境詳細
    ├── CONTRIBUTING.md   # 貢献ガイド
    └── LICENSE           # MIT License

---

## Quick Start

### 1. 前提条件の確認

    # PowerShell バージョン確認（5.1 以上を推奨）
    $PSVersionTable.PSVersion

    # Microsoft Graph モジュールのインストール
    Install-Module Microsoft.Graph -Scope CurrentUser

### 2. スクリプトの取得

    git clone https://github.com/sintana1121/sintana.git
    cd sintana/m365-admin-scripts

### 3. 実行例

    # ライセンスレポートを出力
    .\license\Get-M365LicenseReport.ps1

    # MFA 状況をスキャン
    .\security\Get-MFAStatus.ps1

> 初回実行時、Microsoft アカウントでの認証ダイアログが表示されます。

---

## Script Catalog

| Category | Script | Description |
|----------|--------|-------------|
| License | `Get-M365LicenseReport.ps1` | 全ユーザーのライセンス割当状況を CSV 出力 |
| Users | `Get-InactiveUsers.ps1` | 90日以上サインインのないアカウントを検出 |
| Security | `Get-MFAStatus.ps1` | 多要素認証（MFA）の設定状況を一覧化 |

各スクリプトは **本番環境で即座に使用可能** な品質です。

---

## Required Permissions

| Script | Required Scopes |
|--------|-----------------|
| `Get-M365LicenseReport` | `User.Read.All`, `Directory.Read.All` |
| `Get-InactiveUsers` | `User.Read.All`, `AuditLog.Read.All` |
| `Get-MFAStatus` | `UserAuthenticationMethod.Read.All`, `User.Read.All` |

各スクリプトは実行時に必要なスコープのみを要求します。

---

## 🚀 AI Integration

本リポジトリのスクリプトは、単体での運用に加え、**AI（Copilot Studio / ChatGPT）に食わせるための正確なデータ**を抽出するクレンジングツールとしても機能します。

### なぜ「正確なデータ抽出」がAI活用の前提になるのか

AIに社内データを読ませる際、最大の障壁は **データの不潔さ** です。

- 古い情報が混在している
- フォーマットが統一されていない
- 誰が最新版か分からない

本リポジトリのスクリプトは、**M365環境から「クリーンなCSV」を抽出**します。これがRAG（Retrieval-Augmented Generation）の土台になります。

### 活用例

| ユースケース | 説明 |
|--------------|------|
| RAG用データ抽出 | スクリプトで出力したCSVを、AIが参照するナレッジベースの素材として活用 |
| Copilot Studio 連携 | Power Automate 経由でスクリプトを呼び出し、AIエージェントの一部として組み込み |
| 定期レポートのAI解析 | 出力CSVをGPTに読ませ、異常検知や傾向分析を自動化 |

### 実装事例

Copilot Studio × SharePoint で構築した社内調査ボットの詳細を公開しています：

👉 [Copilot Studio × SharePoint で社内ナレッジ検索AIを構築する【実践記録】](https://qiita.com/SintanaProduction)

---

## Design Principles

本リポジトリのスクリプトは、20年の現場経験に基づき設計されています。

| 原則 | 説明 |
|------|------|
| **Read-Only** | データの変更・削除は行いません。本番環境で安全に実行可能です。 |
| **Self-Contained** | 外部設定ファイルに依存せず、スクリプト単体で完結します。 |
| **Defensive Coding** | Try-Catch による例外処理と、詳細なエラーメッセージを完備しています。 |
| **Comment-Based Help** | すべてのスクリプトに `Get-Help` 対応のドキュメントを内包。 |

    Get-Help .\license\Get-M365LicenseReport.ps1 -Full

---

## Troubleshooting

### モジュールが見つからない

    用語 'Connect-MgGraph' は、コマンドレット...として認識されません

**Solution:**

    Install-Module Microsoft.Graph -Scope CurrentUser -Force
    Import-Module Microsoft.Graph.Users
    Import-Module Microsoft.Graph.Identity.DirectoryManagement

### 権限エラー

    Insufficient privileges to complete the operation

**Solution:**  
グローバル管理者、または適切な Azure AD ロールを持つアカウントで再実行してください。

### 実行ポリシーエラー

    このシステムではスクリプトの実行が無効になっている...

**Solution:**

    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

詳細は `requirements.md` を参照してください。

---

## For Enterprise Use

本リポジトリのスクリプトは **単発の情報取得** に特化しています。

以下のような高度な自動化・仕組み化が必要な場合は、商用版ソリューションをご検討ください：

- 定期実行・異常検知通知
- AIエージェント構築（Copilot Studio）
- 複数テナント対応（MSP/マネージドサービス向け）
- ガバナンス設計・導入コンサルティング

👉 [Sintana Production - 業務改善の詳細を見る](https://sintana.site)

---

## Technical Articles

M365 管理の実務ノウハウは Qiita で公開しています。

- [M365管理センターで最初にやるべき10の設定](https://qiita.com/SintanaProduction/items/22a5c88b04d730bf0323)
- [【M365】「30分で作った承認フロー」が現場でゴミになる3つの理由と、回避するための実践ガイド](https://qiita.com/SintanaProduction/items/1bdad66207e1f4436b39)

---

## Author

**Sintana**

Microsoft 365 の設計・運用を専門とする戦略的協力者。  
「現場の汗」と「クラウドの知見」を繋ぎ、属人化を消し去る仕組みを構築します。

- **Note:** [sintana2222](https://note.com/sintana2222)
- **Qiita:** [@SintanaProduction](https://qiita.com/SintanaProduction)
- **X (Twitter):** [@sintana2222](https://twitter.com/sintana2222)
- **Official Site:** [sintana.site](https://sintana.site)

---

## License

MIT License

---

## Disclaimer

- 本スクリプトの使用によって生じた損害について、作者は一切の責任を負いません。
- 必ずテスト環境で動作を確認してから本番環境で実行してください。
- Microsoft Graph API の仕様変更により、動作しなくなる可能性があります。
