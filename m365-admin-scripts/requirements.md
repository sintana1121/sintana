# Requirements / 前提条件

本リポジトリのスクリプトを実行するために必要な環境です。

---

## Environment

### PowerShell

- **PowerShell 5.1** 以上（Windows 10/11 標準搭載）
- または **PowerShell 7.x**（クロスプラットフォーム）

バージョン確認:
```powershell
$PSVersionTable.PSVersion
```

### Microsoft Graph PowerShell SDK

```powershell
# インストール（初回のみ）
Install-Module Microsoft.Graph -Scope CurrentUser

# バージョン確認
Get-Module Microsoft.Graph -ListAvailable

# アップデート
Update-Module Microsoft.Graph
```

**推奨バージョン:** 2.0 以上

---

## Microsoft 365 Subscription

以下のいずれかのライセンスが必要です。

| プラン | 対応 |
|--------|:----:|
| Microsoft 365 Business Basic | ✅ |
| Microsoft 365 Business Standard | ✅ |
| Microsoft 365 Business Premium | ✅ |
| Microsoft 365 E3 | ✅ |
| Microsoft 365 E5 | ✅ |
| Office 365 E1/E3/E5 | ✅ |

---

## Permissions

### Permission Reference

| Category | Required Scopes |
|----------|-----------------|
| License | `User.Read.All`, `Directory.Read.All` |
| Users | `User.Read.All`, `AuditLog.Read.All` |
| Security | `UserAuthenticationMethod.Read.All`, `RoleManagement.Read.Directory` |
| SharePoint | `Sites.Read.All`, `Reports.Read.All` |
| Audit | `AuditLog.Read.All`, `Mail.Read` |

### Account Requirements

スクリプトを実行するアカウントには、以下のいずれかが必要です。

| Role | 説明 |
|------|------|
| グローバル管理者 | すべてのスクリプトを実行可能 |
| グローバル閲覧者 | ほとんどの読み取り操作が可能 |
| レポート閲覧者 | レポート関連のスクリプトのみ |
| セキュリティ閲覧者 | セキュリティ関連のスクリプトのみ |

**推奨:** 日常的な監査には「グローバル閲覧者」ロールを持つ専用アカウントの作成を推奨します。

---

## Authentication

### Interactive Authentication（対話型）

初回実行時、ブラウザが開き Microsoft アカウントでのサインインが求められます。

```powershell
Connect-MgGraph -Scopes "User.Read.All", "Directory.Read.All"
```

### App-Only Authentication（アプリ専用）

自動実行（スケジュールタスク等）の場合は、アプリ登録が必要です。

1. Azure Portal で「アプリの登録」
2. API のアクセス許可を設定（アプリケーションの許可）
3. 管理者の同意を付与
4. クライアントシークレットまたは証明書を作成

```powershell
Connect-MgGraph -ClientId "your-app-id" -TenantId "your-tenant-id" -CertificateThumbprint "thumbprint"
```

詳細は [Microsoft Graph SDK 認証ガイド](https://docs.microsoft.com/ja-jp/powershell/microsoftgraph/get-started) を参照してください。

---

## Troubleshooting

### モジュールが見つからない

```
用語 'Connect-MgGraph' は、コマンドレット、関数、スクリプト ファイル、
または操作可能なプログラムの名前として認識されません。
```

**Solution:**
```powershell
# モジュールを再インストール
Install-Module Microsoft.Graph -Scope CurrentUser -Force

# 必要なサブモジュールをインポート
Import-Module Microsoft.Graph.Users
Import-Module Microsoft.Graph.Identity.DirectoryManagement
Import-Module Microsoft.Graph.Reports
```

### 権限エラー

```
Insufficient privileges to complete the operation.
```

**Solution:**
- グローバル管理者または適切なロールを持つアカウントで再実行
- 必要なスコープを指定して再接続

```powershell
Disconnect-MgGraph
Connect-MgGraph -Scopes "User.Read.All", "Directory.Read.All", "AuditLog.Read.All"
```

### 実行ポリシーエラー

```
このシステムではスクリプトの実行が無効になっているため、
ファイル ... を読み込むことができません。
```

**Solution:**
```powershell
# 現在のユーザーに対してのみ許可（推奨）
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# 確認
Get-ExecutionPolicy -List
```

### TLS エラー

```
The request was aborted: Could not create SSL/TLS secure channel.
```

**Solution:**
```powershell
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
```

### 接続タイムアウト

大規模テナントで全ユーザーを取得する際にタイムアウトする場合：

```powershell
# ページング処理を明示的に指定
$users = Get-MgUser -All -PageSize 100
```

---

## Best Practices

### 専用アカウントの作成

日常的なスクリプト実行用に、専用の管理アカウントを作成することを推奨します。

- 「グローバル閲覧者」ロールを割り当て
- MFA を必須に設定
- サインインログを定期的に確認

### 定期実行の設定

Windows タスクスケジューラでの設定例：

```
プログラム: powershell.exe
引数: -ExecutionPolicy Bypass -File "C:\Scripts\Get-M365LicenseReport.ps1"
開始: C:\Scripts
```

※ App-Only 認証の設定が必要です。

### ログの保存

出力先を共有フォルダやクラウドストレージに設定し、履歴を保存：

```powershell
$timestamp = Get-Date -Format "yyyyMMdd"
.\Get-M365LicenseReport.ps1 -OutputPath "\\server\share\M365Reports\License_$timestamp.csv"
```

---

## Reference

- [Microsoft Graph PowerShell SDK](https://docs.microsoft.com/ja-jp/powershell/microsoftgraph/)
- [Microsoft Graph permissions reference](https://docs.microsoft.com/en-us/graph/permissions-reference)
- [Azure AD built-in roles](https://docs.microsoft.com/en-us/azure/active-directory/roles/permissions-reference)
