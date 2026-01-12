# Contributing / 貢献ガイド

このリポジトリへの貢献を歓迎します！

## 貢献の方法

### バグ報告

1. [Issues](https://github.com/sintana1121/m365-admin-scripts/issues) を確認し、同じ問題が報告されていないか確認
2. 新しい Issue を作成
3. 以下の情報を含めてください：
   - スクリプト名
   - エラーメッセージ
   - 実行環境（PowerShell バージョン、OS）
   - 再現手順

### 機能リクエスト

1. [Issues](https://github.com/sintana1121/m365-admin-scripts/issues) で Feature Request を作成
2. 何を実現したいか具体的に記載

### プルリクエスト

1. Fork してください
2. ブランチを作成: `git checkout -b feature/your-feature`
3. 変更をコミット: `git commit -m 'Add some feature'`
4. プッシュ: `git push origin feature/your-feature`
5. Pull Request を作成

## コーディング規約

### スクリプトの形式

```powershell
<#
.SYNOPSIS
    簡潔な説明

.DESCRIPTION
    詳細な説明

.PARAMETER ParamName
    パラメータの説明

.EXAMPLE
    使用例

.NOTES
    Author: Your Name
#>

[CmdletBinding()]
param(
    [Parameter()]
    [string]$ParamName
)

# メイン処理
```

### 命名規則

- スクリプト名: `Get-*`, `Export-*`, `Set-*` など動詞-名詞形式
- 変数名: キャメルケース `$userName`
- 関数名: パスカルケース `Get-UserInfo`

### コメント

- 英語または日本語
- 複雑な処理には必ずコメントを追加

## 質問

質問があれば、Issue を作成するか、X ([@sintana2222](https://x.com/sintana2222)) でお気軽にどうぞ。
