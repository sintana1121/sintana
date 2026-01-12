# User Management / ユーザー管理

M365 ユーザーアカウントの状態把握と棚卸しのためのスクリプト集。

---

## Why This Matters

ユーザーアカウントは M365 テナントの基盤です。

放置されると発生する問題：
- 退職者アカウントが残り続ける（セキュリティリスク）
- 誰も使っていないアカウントにライセンス費用がかかる
- 部署異動が反映されず、権限が不適切なまま
- アカウント一覧を求められても即座に出せない

**管理者が「全ユーザーの状態」を把握できていないのは危険。**

---

## Scripts

| Script | Description |
|--------|-------------|
| [Get-InactiveUsers.ps1](./Get-InactiveUsers.ps1) | 長期間サインインのないユーザーを検出 |

---

## Get-InactiveUsers.ps1

指定日数以上サインインしていないユーザーを抽出します。

### Output Sample

| DisplayName | UPN | LastSignIn | DaysSinceSignIn | AccountEnabled | HasLicense |
|-------------|-----|------------|-----------------|----------------|------------|
| 休職中A | leave@contoso.com | 2024-06-15 | **210** | True | True |
| 派遣終了B | temp@contoso.com | 2024-09-01 | **133** | True | True |
| テストユーザー | test@contoso.com | - | **Never** | True | False |

`DaysSinceSignIn > 90` かつ `HasLicense = True` は **コスト削減の候補** です。

### Usage

```powershell
# 基本実行（90日以上非アクティブ）
.\Get-InactiveUsers.ps1

# 閾値を変更（60日）
.\Get-InactiveUsers.ps1 -InactiveDays 60

# 出力先を指定
.\Get-InactiveUsers.ps1 -OutputPath "C:\Reports\inactive.csv"
```

### Required Permissions

| Scope | Purpose |
|-------|---------|
| User.Read.All | ユーザー情報の読み取り |
| AuditLog.Read.All | サインイン履歴の読み取り |

---

## Practical Use Cases

### 四半期レビュー

```
1. Export-UserReport.ps1 で全ユーザーを出力
2. 部門長に配布し「この人、まだいますか？」を確認
3. 退職者・異動者を特定し、アカウント処理
```

### コスト削減プロジェクト

```
1. Get-InactiveUsers.ps1 で非アクティブユーザーを抽出
2. 各ユーザーの所属部門に確認
3. 不要と判断されたらライセンス回収
4. 必要に応じてアカウント無効化
```

### 監査対応

```
1. Export-UserReport.ps1 で全ユーザーを出力
2. Get-InactiveUsers.ps1 で非アクティブを出力
3. 2つのレポートを監査人に提出
4. 「全体像」と「問題候補」を同時に提示
```

---

## Limitations

本スクリプトで対応可能な範囲：

✅ ユーザー情報の **一括出力**  
✅ 非アクティブユーザーの **検出**  
✅ CSV による **レポート出力**

本スクリプトでは対応しない範囲：

❌ ユーザーの **作成・削除**（変更操作）  
❌ パスワードの **リセット**  
❌ グループメンバーシップの **分析**  
❌ 定期実行の **スケジューリング**

---

## Related Resources

- [Qiita: M365ユーザー管理の自動化](https://qiita.com/SintanaProduction)
- [Microsoft Entra admin center](https://entra.microsoft.com)

---

## Going Further

ユーザー管理は「状況把握」と「運用ルールの整備」がセットです。

「把握した後、どう運用を回すか」については、  
体系的なガイドで解説しています。

- **業務仕組み化テンプレPack**: 入退社フロー、権限管理のベストプラクティス
- **技術記事**: Qiita で実践ノウハウを公開中

詳細は [sintana.site](https://sintana.site) をご覧ください。
