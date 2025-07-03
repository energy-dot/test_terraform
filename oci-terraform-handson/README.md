# OCI Free Tier Terraform ハンズオン

Oracle Cloud Infrastructure (OCI) の無料枠（Always Free）を使用して、Terraformによるインフラ構築を学ぶハンズオン資料です。

## 概要

このリポジトリでは、OCIのAlways Free枠を使用して、以下のリソースをTerraformで構築します：

- コンパートメント
- 仮想クラウドネットワーク (VCN)
- サブネット
- インターネットゲートウェイ
- ルートテーブル
- セキュリティリスト
- Ampere A1コンピュートインスタンス
- ブロックボリューム

## ドキュメント

詳細なドキュメントは以下を参照してください：

- [ハンズオン詳細ガイド](./docs/README.md) - ハンズオンの詳細な手順と解説
- [Terraformコード詳細解説](./docs/terraform_code_explanation.md) - Terraformコードの詳細な解説
- [OCI認証情報のセットアップガイド](./docs/oci_credentials_setup.md) - OCI認証情報の設定方法

## 前提条件

- [OCIアカウント](https://www.oracle.com/cloud/free/)
- [Terraform](https://www.terraform.io/downloads.html) (バージョン1.0.0以上)
- SSH鍵ペア

## クイックスタート

```bash
# リポジトリのクローン
git clone https://github.com/yourusername/oci-terraform-handson.git
cd oci-terraform-handson

# 変数ファイルの設定
cp terraform.tfvars.example terraform.tfvars
# エディタでterraform.tfvarsを編集し、認証情報を設定

# Terraformの初期化
terraform init

# 実行計画の確認
terraform plan

# インフラのデプロイ
terraform apply

# 完了後のクリーンアップ
terraform destroy
```

## プロジェクト構造

```
oci-terraform-handson/
├── main.tf           # メインのTerraformコード
├── variables.tf      # 変数の定義
├── datasources.tf    # データソース（既存リソースの参照）
├── outputs.tf        # 出力値の定義
├── terraform.tfvars  # 変数の値（gitignoreに追加推奨）
└── docs/             # ドキュメント
    ├── README.md                    # ハンズオン詳細ガイド
    ├── terraform_code_explanation.md # Terraformコード詳細解説
    └── oci_credentials_setup.md     # OCI認証情報のセットアップガイド
```

## 注意事項

- このハンズオンはOCIのAlways Free枠を使用しますが、設定によっては課金が発生する可能性があります。
- 使用後は`terraform destroy`コマンドでリソースを削除することをお勧めします。
- `terraform.tfvars`ファイルには機密情報が含まれるため、バージョン管理システムにコミットしないでください。

## ライセンス

このプロジェクトはMITライセンスの下で公開されています。詳細は[LICENSE](LICENSE)ファイルを参照してください。

## 貢献

バグ報告や機能リクエストは、GitHubのIssueで受け付けています。プルリクエストも歓迎します。