# Contributing / 貢献ガイド

このリポジトリへの貢献を歓迎します。

---

## How to Contribute

### Bug Reports

1. [Issues](https://github.com/sintana1121/sintana/issues) で同様の報告がないか確認
2. 新しい Issue を作成
3. 以下の情報を含めてください：
   - スクリプト名
   - エラーメッセージ（全文）
   - 実行環境（PowerShell バージョン、OS、Graph SDK バージョン）
   - 再現手順

### Feature Requests

1. [Issues](https://github.com/sintana1121/sintana/issues) で Feature Request を作成
2. 何を実現したいか、なぜ必要かを具体的に記載
3. 可能であれば、期待する出力形式も提示

### Pull Requests

1. Fork してください
2. ブランチを作成: `git checkout -b feature/your-feature`
3. 変更をコミット: `git commit -m 'Add: 機能の説明'`
4. プッシュ: `git push origin feature/your-feature`
5. Pull Request を作成

---

## Coding Standards

### Script Structure

すべてのスクリプトは以下の構造に従ってください。

```powershell
<#
.SYNOPSIS
    簡潔な説明（1行）

.DESCRIPTION
    詳細な説明
    - 何をするスクリプトか
    - どのような出力を生成するか
    - 読み取り専用であることの明記

.PARAMETER ParamName
    パラメータの説明

.EXAMPLE
    使用例1

.EXAMPLE
    使用例2

.NOTES
    =======================================================================
    Script:       Get-ScriptName.ps1
    Author:       Your Name
    Version:      1.0.0
    Created:      YYYY-MM-DD
    Updated:      YYYY-MM-DD
    GitHub:       https://github.com/sintana1121/sintana/tree/main/m365-admin-scripts
    =======================================================================
    
    REQUIREMENTS:
    - 必要な環境
    
    REQUIRED PERMISSIONS:
    - 必要なスコープ
    
    CHANGE LOG:
    - バージョン履歴
#>

#Requires -Version 5.1

[CmdletBinding()]
param(
    # パラメータ定義
)

# Constants
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Functions
function Write-Log { ... }

# Main
try {
    # メイン処理
}
catch {
    # エラー処理
}
finally {
    # クリーンアップ
}
```

### Naming Conventions

| 対象 | 規則 | 例 |
|------|------|-----|
| スクリプト名 | 動詞-名詞 (PascalCase) | `Get-M365LicenseReport.ps1` |
| 関数名 | 動詞-名詞 (PascalCase) | `Get-UserInfo` |
| 変数名 | camelCase | `$userName`, `$licenseList` |
| 定数 | UPPER_SNAKE_CASE | `$SCRIPT_VERSION`, `$REQUIRED_SCOPES` |
| パラメータ名 | PascalCase | `-OutputPath`, `-InactiveDays` |

### Approved Verbs

PowerShell の承認された動詞を使用してください。

| 動作 | 動詞 |
|------|------|
| データ取得 | `Get-` |
| データ出力 | `Export-` |
| データ検索 | `Find-` |
| データ比較 | `Compare-` |
| レポート生成 | `New-` (Report) |

参考: [Approved Verbs for PowerShell Commands](https://docs.microsoft.com/en-us/powershell/scripting/developer/cmdlet/approved-verbs-for-windows-powershell-commands)

### Error Handling

- すべてのスクリプトは `Try-Catch-Finally` を使用
- エラーメッセージは具体的に
- 可能な限りユーザーフレンドリーなメッセージを表示

```powershell
try {
    $users = Get-MgUser -All
}
catch {
    Write-Log "ユーザー情報の取得に失敗しました: $($_.Exception.Message)" -Level Error
    throw
}
```

### Comments

- 複雑なロジックには必ずコメントを追加
- コメントは英語または日本語（混在可）
- 「なぜ」を説明するコメントを重視

```powershell
# Filter out service accounts (their UPN starts with underscore)
# サービスアカウント（UPNがアンダースコアで始まる）を除外
$users = $users | Where-Object { -not $_.UserPrincipalName.StartsWith("_") }
```

---

## Testing

### Manual Testing

Pull Request 前に以下を確認：

1. テスト環境で動作確認済み
2. エラーハンドリングが正常に動作する
3. 出力 CSV が正しいフォーマットである
4. `Get-Help` でドキュメントが表示される

### Pester Tests (Future)

将来的に Pester によるユニットテストを導入予定です。

---

## Documentation

### README Updates

新しいスクリプトを追加する場合：

1. カテゴリの README.md にスクリプト情報を追加
2. ルートの README.md の Script Catalog を更新
3. requirements.md の Permission Reference を更新（新しいスコープがある場合）

---

## Questions

質問があれば、以下にお気軽にどうぞ：

- GitHub Issues
- X: [@sintana2222](https://x.com/sintana2222)
