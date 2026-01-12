# License Management / ライセンス管理

M365 ライセンスの可視化と棚卸しのためのスクリプト集。

---

## Why This Matters

M365 ライセンスコストは中小企業にとって無視できない固定費です。

典型的な問題：
- 退職者にライセンスが割り当てられたまま
- 使っていない機能のために上位プランを契約している
- 誰が何のライセンスを持っているか把握できていない

**Business Premium 1ライセンス = 年間約30,000円**

10人分の無駄があれば、**年間30万円** を捨てていることになります。

---

## Scripts

| Script | Description |
|--------|-------------|
| [Get-M365LicenseReport.ps1](./Get-M365LicenseReport.ps1) | 全ユーザーのライセンス割当状況を一覧出力 |

---

## Get-M365LicenseReport.ps1

テナント内の全ユーザーのライセンス状況を CSV で出力します。

### Output Sample

| DisplayName | UPN | Enabled | Department | LicenseCount | Licenses |
|-------------|-----|---------|------------|--------------|----------|
| 山田 太郎 | yamada@contoso.com | True | 営業部 | 1 | O365_BUSINESS_PREMIUM |
| 退職者A | former@contoso.com | **False** | - | **1** | O365_BUSINESS_PREMIUM |

`Enabled = False` かつ `LicenseCount > 0` のユーザーは、**即座にライセンスを回収すべき対象** です。

### Usage

```powershell
# 基本実行（デスクトップに出力）
.\Get-M365LicenseReport.ps1

# 出力先を指定
.\Get-M365LicenseReport.ps1 -OutputPath "C:\Reports\license.csv"
```

### Required Permissions

| Scope | Purpose |
|-------|---------|
| User.Read.All | ユーザー情報の読み取り |
| Directory.Read.All | ライセンス情報の読み取り |

---

## Practical Use Cases

### 月次棚卸しワークフロー

```
1. Get-M365LicenseReport.ps1 を実行
2. CSV を Excel で開き、ピボットテーブルで集計
3. 部署別・ライセンス種別でコスト把握
4. Get-UnusedLicenses.ps1 で無駄を検出
5. 該当者に確認 → ライセンス回収
```

### 年度末の一括棚卸し

```
1. 全ユーザーレポートを出力
2. 部門長に「この人、本当に必要？」を確認依頼
3. 不要分を回収し、年間予算を削減
```

---

## Limitations

本スクリプトで対応可能な範囲：

✅ ライセンス割当状況の **可視化**  
✅ 無駄なライセンスの **検出**  
✅ CSV による **レポート出力**

本スクリプトでは対応しない範囲：

❌ ライセンスの **自動回収**（削除操作）  
❌ サービスプラン単位の **詳細分析**  
❌ コスト計算の **自動化**  
❌ 定期実行の **スケジューリング**

---

## Related Resources

- [Qiita: M365ライセンス棚卸しの実践ガイド](https://qiita.com/SintanaProduction)
- [Microsoft 365 管理センター](https://admin.microsoft.com)

---

## Going Further

本スクリプトは「状況把握」に特化しています。

「把握した後、どう改善するか」については、  
以下のリソースで体系的に解説しています。

- **業務仕組み化テンプレPack**: ライセンス管理を含む M365 運用の完全ガイド
- **技術記事**: Qiita で実践ノウハウを公開中

詳細は [sintana.site](https://sintana.site) をご覧ください。
