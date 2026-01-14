Markdown# m365-admin-scripts

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

m365-admin-scripts/├── license/          # ライセンス管理│   └── Get-M365LicenseReport.ps1│├── users/            # ユーザー管理│   └── Get-InactiveUsers.ps1│├── security/         # セキュリティ監査│   └── Get-MFAStatus.ps1│├── requirements.md   # 実行環境詳細├── CONTRIBUTING.md   # 貢献ガイド└── LICENSE           # MIT License
---

## Quick Start

### 1. 前提条件の確認
```powershell
# PowerShell バージョン確認（5.1 以上を推奨）
$PSVersionTable.PSVersion

# Microsoft Graph モジュールのインストール
Install-Module Microsoft.Graph -Scope CurrentUser
2. 実行例PowerShell# ライセンスレポートを出力
.\license\Get-M365LicenseReport.ps1

# MFA 状況をスキャン
.\security\Get-MFAStatus.ps1
※ 初回実行時、Microsoft アカウントでの認証ダイアログが表示されます。Script CatalogCategoryScriptDescriptionLicenseGet-M365LicenseReport.ps1全ユーザーのライセンス割当状況を CSV 出力UsersGet-InactiveUsers.ps190日以上サインインのないアカウントを検出SecurityGet-MFAStatus.ps1多要素認証（MFA）の設定状況を一覧化Future & AI Integration本リポジトリのスクリプトは、**「AI（Copilot Studio / ChatGPT）に食わせるための正確なデータ」**を抽出するクレンジングツールとしても機能します。RAG（検索拡張生成）の最適化: AIが参照するデータからノイズを排除し、回答精度を向上させます。AIエージェント連携: Power Automate を介して、これらのスクリプトを AI から呼び出すカスタムアクションを開発中です。最新の AI × Microsoft 365 実装事例 は Qiita 記事 を参照してください。Design Principles本リポジトリのスクリプトは、20年の現場経験に基づき設計されています。Read-Only: データの変更・削除は行いません。本番環境で安全に実行可能です。Self-Contained: 外部設定ファイルに依存せず、スクリプト単体で完結します。Defensive Coding: Try-Catch による例外処理と、詳細なエラーメッセージを完備しています。For Enterprise Use本リポジトリのスクリプトは 単発の情報取得 に特化しています。以下のような高度な自動化・仕組み化が必要な場合は、商用版ソリューションをご検討ください。定期実行・異常検知通知AIエージェント構築（Copilot Studio）ガバナンス設計・導入コンサルティング👉 Sintana Production - 業務改善の詳細を見るAuthorSintana Microsoft 365 の設計・運用を専門とする戦略的協力者。「現場の汗」と「クラウドの知見」を繋ぎ、属人化を消し去る仕組みを構築します。Note: sintana2222（ITと組織の在り方を語る）Qiita: @SintanaProduction（実戦的な技術解説）X (Twitter): @sintana2222Official Site: sintana.siteLicenseMIT LicenseDisclaimer本スクリプトの使用によって生じた損害について、作者は一切の責任を負いません。必ずテスト環境で動作を確認してから本番環境で実行してください。
