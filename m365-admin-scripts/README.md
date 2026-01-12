# m365-admin-scripts

Microsoft 365 管理者向けの PowerShell スクリプト集です。

Graph PowerShell を使った実践的なスクリプトを公開しています。

## 🎯 対象者

- M365 テナントを管理している情シス担当者
- IT 担当がいない中小企業の管理者
- ライセンス管理や棚卸しを効率化したい方

## 📁 スクリプト一覧

| カテゴリ | 説明 | 本数 |
|----------|------|------|
| [license](./license) | ライセンス管理 | 1 |

※ 順次追加予定

## 🚀 使い方

### 1. 必要なモジュールをインストール

```powershell
Install-Module Microsoft.Graph -Scope CurrentUser
```

### 2. スクリプトをダウンロード

```powershell
git clone https://github.com/sintana1121/m365-admin-scripts.git
```

または、各スクリプトを直接ダウンロードしてください。

### 3. 実行

```powershell
.\license\Get-M365LicenseReport.ps1
```

初回実行時に Microsoft アカウントでの認証が求められます。

## 📋 必要な環境

詳細は [requirements.md](./requirements.md) を参照してください。

- PowerShell 5.1 以上
- Microsoft Graph PowerShell モジュール
- Microsoft 365 管理者アカウント

## 🔐 必要な権限

| スクリプト | 必要な権限 |
|-----------|-----------|
| Get-M365LicenseReport.ps1 | User.Read.All, Directory.Read.All |

## ⚠️ 注意事項

- 本番環境で実行する前に、必ずテスト環境で動作確認してください
- スクリプトは「読み取り専用」の操作のみ行います（データの変更・削除は行いません）
- 実行にはテナントの管理者権限が必要です

## 📖 関連記事

- [M365管理センターで最初にやるべき10の設定](https://qiita.com/SintanaProduction) - Qiita

## 💡 完成品が欲しい方へ

これらのスクリプトは単機能の部品です。

**「業務でそのまま使えるテンプレート一式」** が欲しい方は、こちらをご覧ください。

👉 [業務仕組み化テンプレPack - 無料で第1章を配布中](https://sintana.site)

## ☕ サポート

このリポジトリが役に立ったら、GitHub Sponsors で応援してください。

[![GitHub Sponsors](https://img.shields.io/badge/Sponsor-GitHub%20Sponsors-ea4aaa)](https://github.com/sponsors/sintana1121)

## 📝 ライセンス

[MIT License](./LICENSE)

## 👤 作成者

**シンタナ (Sintana)**

- GitHub: [@sintana1121](https://github.com/sintana1121)
- Qiita: [@SintanaProduction](https://qiita.com/SintanaProduction)
- X: [@sintana2222](https://x.com/sintana2222)
