# Requirements / 前提条件

このリポジトリのスクリプトを実行するために必要な環境です。

## PowerShell

- PowerShell 5.1 以上（Windows 10/11 標準搭載）
- または PowerShell 7.x

バージョン確認:
```powershell
$PSVersionTable.PSVersion
```

## Microsoft Graph PowerShell モジュール

### インストール

```powershell
# 初回のみ
Install-Module Microsoft.Graph -Scope CurrentUser
```

### 確認

```powershell
Get-Module Microsoft.Graph -ListAvailable
```

### アップデート

```powershell
Update-Module Microsoft.Graph
```

## Microsoft 365 アカウント

- Microsoft 365 Business Basic / Standard / Premium
- または Microsoft 365 E3 / E5

### 必要な権限

スクリプトによって必要な権限が異なります。各スクリプトのREADMEを参照してください。

| 権限 | 用途 |
|------|------|
| User.Read.All | ユーザー情報の読み取り |
| Directory.Read.All | ディレクトリ情報の読み取り |
| Group.Read.All | グループ情報の読み取り |
| Sites.Read.All | SharePointサイト情報の読み取り |
| Mail.Read | メール情報の読み取り |
| AuditLog.Read.All | 監査ログの読み取り |

### 認証方法

スクリプト実行時に対話的な認証が求められます。

```powershell
Connect-MgGraph -Scopes "User.Read.All", "Directory.Read.All"
```

ブラウザが開き、Microsoft アカウントでサインインしてください。

## トラブルシューティング

### モジュールが見つからない

```
用語 'Connect-MgGraph' は、コマンドレット...として認識されません
```

**解決策:**
```powershell
Install-Module Microsoft.Graph -Scope CurrentUser -Force
Import-Module Microsoft.Graph.Users
Import-Module Microsoft.Graph.Identity.DirectoryManagement
```

### 権限エラー

```
Insufficient privileges to complete the operation
```

**解決策:**
- グローバル管理者または適切な権限を持つアカウントで実行
- 必要なスコープを指定して再接続

```powershell
Disconnect-MgGraph
Connect-MgGraph -Scopes "User.Read.All", "Directory.Read.All"
```

### 実行ポリシーエラー

```
このシステムではスクリプトの実行が無効になっている...
```

**解決策:**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## 参考リンク

- [Microsoft Graph PowerShell SDK](https://docs.microsoft.com/ja-jp/powershell/microsoftgraph/)
- [Microsoft Graph permissions reference](https://docs.microsoft.com/en-us/graph/permissions-reference)
