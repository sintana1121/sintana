# Security Audit / セキュリティ監査

M365 テナントのセキュリティ状態を可視化するスクリプト集。

---

## Why This Matters

中小企業の M365 環境で最も見落とされているのが **セキュリティ設定** です。

よくある危険な状態：
- MFA（多要素認証）が全員に適用されていない
- グローバル管理者が 5人以上いる
- 退職者に管理者権限が残っている
- 誰が管理者か、そもそも把握していない

**1つのアカウントが侵害されれば、会社の全データが危険にさらされる。**

---

## Scripts

| Script | Description |
|--------|-------------|
| [Get-MFAStatus.ps1](./Get-MFAStatus.ps1) | 全ユーザーの MFA 設定状況を確認 |

---

## Get-MFAStatus.ps1

テナント内の全ユーザーの多要素認証（MFA）設定状況を出力します。

### Output Sample

| DisplayName | UPN | MFAStatus | DefaultMethod | Methods |
|-------------|-----|-----------|---------------|---------|
| 山田 太郎 | yamada@contoso.com | Enabled | PhoneAuth | PhoneAuth, Email |
| 鈴木 花子 | suzuki@contoso.com | **Disabled** | - | - |
| 佐藤 一郎 | sato@contoso.com | Enabled | Authenticator | Authenticator |

`MFAStatus = Disabled` のユーザーは **即座に対応が必要** です。

### Usage

```powershell
# 基本実行
.\Get-MFAStatus.ps1

# 出力先を指定
.\Get-MFAStatus.ps1 -OutputPath "C:\SecurityAudit\mfa.csv"
```

### Required Permissions

| Scope | Purpose |
|-------|---------|
| UserAuthenticationMethod.Read.All | 認証方法の読み取り |
| User.Read.All | ユーザー情報の読み取り |

---

## Security Checklist

本スクリプトの出力を使って、以下を確認してください。

- [ ] 全ユーザーに MFA が有効になっているか
- [ ] 管理者は特に強力な認証方法（Authenticator アプリ）を使っているか
- [ ] 例外ユーザー（MFA 無効）がいる場合、その理由は妥当か

---

## Limitations

本スクリプトで対応可能な範囲：

✅ MFA 状態の **可視化**  
✅ 管理者ロールの **一覧出力**  
✅ CSV による **レポート出力**

本スクリプトでは対応しない範囲：

❌ MFA の **強制有効化**（設定変更操作）  
❌ 管理者ロールの **自動削除**  
❌ 条件付きアクセスポリシーの **分析**  
❌ リスクベース認証の **監視**

---

## Related Resources

- [Qiita: M365セキュリティ設定で最初にやるべき5つのこと](https://qiita.com/SintanaProduction)
- [Microsoft Entra admin center](https://entra.microsoft.com)

---

## Going Further

セキュリティ監査は「状況把握」が第一歩です。

「把握した後、どう対策するか」については、  
体系的なガイドで解説しています。

- **業務仕組み化テンプレPack**: セキュリティ設定を含む運用ベストプラクティス
- **技術記事**: Qiita で実践ノウハウを公開中

詳細は [sintana.site](https://sintana.site) をご覧ください。
