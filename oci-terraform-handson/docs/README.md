# Oracle Cloud Infrastructure (OCI) Free Tier ハンズオン

このハンズオンでは、Oracle Cloud Infrastructure (OCI) の無料枠（Always Free）を使用して、Terraformによるインフラ構築を学びます。

## 目次

1. [はじめに](#はじめに)
2. [OCI Free Tierについて](#oci-free-tierについて)
3. [前提条件](#前提条件)
4. [環境構築手順](#環境構築手順)
5. [Terraformコードの解説](#terraformコードの解説)
6. [リソースの確認方法](#リソースの確認方法)
7. [クリーンアップ](#クリーンアップ)
8. [トラブルシューティング](#トラブルシューティング)
9. [発展課題](#発展課題)

## はじめに

Infrastructure as Code (IaC) は、インフラストラクチャをコードとして管理・プロビジョニングする方法です。Terraformは、HashiCorp社が開発したオープンソースのIaCツールで、複数のクラウドプロバイダに対応しています。

このハンズオンでは、OCIのAlways Free枠を使用して、以下のリソースをTerraformで構築します：

- コンパートメント（リソース管理用の論理的なグループ）
- 仮想クラウドネットワーク (VCN)
- サブネット
- インターネットゲートウェイ
- ルートテーブル
- セキュリティリスト
- Ampere A1コンピュートインスタンス（Always Free対象）
- ブロックボリューム

## OCI Free Tierについて

Oracle Cloud Infrastructure (OCI) のFree Tierには、以下の2種類があります：

1. **Always Free** - 無期限で使用できる無料リソース
2. **Free Trial** - 30日間または$300分の無料クレジット（先に達した方が終了）

このハンズオンでは、**Always Free**リソースに焦点を当てます。

### Always Freeの主なリソース

```mermaid
graph TD
    A[OCI Always Free リソース] --> B[コンピュート]
    A --> C[ストレージ]
    A --> D[ネットワーキング]
    A --> E[データベース]
    
    B --> B1[Ampere A1 Flex - 4 OCPUs, 24 GB RAM]
    B --> B2[VM.Standard.E2.1.Micro - 1 OCPU, 1 GB RAM]
    
    C --> C1[ブロックボリューム - 合計200GB]
    C --> C2[オブジェクトストレージ - 20GB]
    C --> C3[ブロックボリュームバックアップ - 5個]
    
    D --> D1[仮想クラウドネットワーク - 2個]
    D --> D2[ロードバランサー - 1個, 10 Mbps]
    
    E --> E1[Autonomous Database - 2個]
    E --> E2[NoSQL Database]
</mermaid>

## 前提条件

このハンズオンを実施するには、以下が必要です：

1. **OCIアカウント** - [OCI Free Tier登録ページ](https://www.oracle.com/cloud/free/)から登録
2. **Terraform** - バージョン1.0.0以上
3. **OCI CLI** - OCIとの認証に使用（オプション）
4. **SSH鍵ペア** - コンピュートインスタンスへの接続に使用

### OCIの認証設定

Terraformを使用してOCIリソースを管理するには、APIキーを設定する必要があります：

1. OCIコンソールにログイン
2. 右上のプロファイルアイコン → ユーザー設定
3. APIキー → APIキーの追加
4. 秘密鍵と公開鍵のペアを生成（または既存のものをアップロード）
5. 表示されるフィンガープリントをメモ

詳細な手順は[OCIドキュメント](https://docs.oracle.com/ja-jp/iaas/Content/API/Concepts/apisigningkey.htm)を参照してください。

## 環境構築手順

### 1. リポジトリのクローン

```bash
git clone https://github.com/yourusername/oci-terraform-handson.git
cd oci-terraform-handson
```

### 2. 変数ファイルの設定

```bash
cp terraform.tfvars.example terraform.tfvars
```

エディタで`terraform.tfvars`を開き、以下の値を設定します：

- **tenancy_ocid** - OCIテナンシーのOCID
- **user_ocid** - OCIユーザーのOCID
- **fingerprint** - APIキーのフィンガープリント
- **private_key_path** - APIキーの秘密鍵のパス
- **region** - 使用するOCIリージョン（例：ap-tokyo-1）
- **ssh_public_key** - SSHの公開鍵の内容

### 3. Terraformの初期化

```bash
terraform init
```

### 4. 実行計画の確認

```bash
terraform plan
```

### 5. インフラのデプロイ

```bash
terraform apply
```

確認メッセージが表示されたら、`yes`と入力します。

## Terraformコードの解説

### プロジェクト構造

```
oci-terraform-handson/
├── main.tf           # メインのTerraformコード
├── variables.tf      # 変数の定義
├── datasources.tf    # データソース（既存リソースの参照）
├── outputs.tf        # 出力値の定義
├── terraform.tfvars  # 変数の値（gitignoreに追加推奨）
└── docs/             # ドキュメント
```

### main.tf

`main.tf`ファイルは、プロジェクトの中心となるファイルで、以下のセクションに分かれています：

#### 1. Terraform設定ブロック

```hcl
terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.0.0"
}
```

このブロックでは：
- **required_providers** - 使用するプロバイダ（この場合はOCI）を指定
- **required_version** - 必要なTerraformのバージョンを指定

#### 2. プロバイダー設定

```hcl
provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}
```

このブロックでは：
- OCIへの認証情報を設定
- 変数を使用して値を外部から注入可能に

#### 3. コンパートメント作成

```hcl
resource "oci_identity_compartment" "tf_compartment" {
  name           = "terraform-compartment"
  description    = "Compartment for Terraform resources"
  compartment_id = var.tenancy_ocid
  
  enable_delete = true
}
```

コンパートメントは、OCIリソースを論理的にグループ化するためのコンテナです：
- **name** - コンパートメントの名前
- **description** - コンパートメントの説明
- **compartment_id** - 親コンパートメントのID（ここではテナンシーのルートコンパートメント）
- **enable_delete** - Terraformによる削除を許可するフラグ

#### 4. ネットワークリソース

```hcl
# 仮想クラウドネットワーク (VCN) 作成
resource "oci_core_vcn" "tf_vcn" {
  compartment_id = oci_identity_compartment.tf_compartment.id
  cidr_blocks    = ["10.0.0.0/16"]
  display_name   = "TerraformVCN"
  dns_label      = "tfvcn"
}
```

VCNは、OCIの仮想ネットワークです：
- **compartment_id** - 作成したコンパートメントのID（参照構文に注目）
- **cidr_blocks** - IPアドレス範囲
- **display_name** - VCNの表示名
- **dns_label** - DNSラベル（VCN内のDNS解決に使用）

```mermaid
graph TB
    VCN[仮想クラウドネットワーク<br>10.0.0.0/16] --> Subnet[パブリックサブネット<br>10.0.1.0/24]
    Subnet --> SL[セキュリティリスト<br>- SSH (22)<br>- HTTP (80)<br>- HTTPS (443)]
    VCN --> IG[インターネットゲートウェイ]
    IG --> RT[ルートテーブル<br>0.0.0.0/0 → IG]
    Subnet --> RT
    
    classDef network fill:#f9f,stroke:#333,stroke-width:2px;
    classDef security fill:#bbf,stroke:#333,stroke-width:2px;
    classDef routing fill:#bfb,stroke:#333,stroke-width:2px;
    
    class VCN,Subnet network;
    class SL security;
    class IG,RT routing;
</mermaid>

#### 5. コンピュートインスタンス

```hcl
resource "oci_core_instance" "tf_instance" {
  availability_domain = data.oci_identity_availability_domain.ad.name
  compartment_id      = oci_identity_compartment.tf_compartment.id
  display_name        = "TerraformInstance"
  shape               = "VM.Standard.A1.Flex"

  shape_config {
    ocpus         = 4
    memory_in_gbs = 24
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.tf_public_subnet.id
    assign_public_ip = true
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.oracle_linux.images[0].id
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
  }
}
```

このブロックでは、Always Free対象のAmpere A1コンピュートインスタンスを作成します：
- **availability_domain** - 可用性ドメイン（データソースから取得）
- **shape** - インスタンスのシェイプ（VM.Standard.A1.Flex = Arm ベースのフレキシブルシェイプ）
- **shape_config** - フレキシブルシェイプの構成（OCPUとメモリ）
- **create_vnic_details** - ネットワークインターフェースの設定
- **source_details** - OSイメージの設定
- **metadata** - インスタンスのメタデータ（SSH公開鍵など）

#### 6. ブロックボリューム

```hcl
resource "oci_core_volume" "tf_block_volume" {
  availability_domain = data.oci_identity_availability_domain.ad.name
  compartment_id      = oci_identity_compartment.tf_compartment.id
  display_name        = "TerraformBlockVolume"
  size_in_gbs         = 100
}

resource "oci_core_volume_attachment" "tf_volume_attachment" {
  attachment_type = "paravirtualized"
  instance_id     = oci_core_instance.tf_instance.id
  volume_id       = oci_core_volume.tf_block_volume.id
}
```

このブロックでは、ブロックボリュームを作成し、インスタンスにアタッチします：
- **size_in_gbs** - ボリュームのサイズ（Always Freeの上限は合計200GB）
- **attachment_type** - アタッチメントのタイプ（paravirtualized = 準仮想化）

### variables.tf

`variables.tf`ファイルでは、プロジェクトで使用する変数を定義します：

```hcl
variable "tenancy_ocid" {
  description = "OCIテナンシーのOCID"
  type        = string
}
```

各変数には以下の属性があります：
- **description** - 変数の説明
- **type** - 変数の型（string, number, bool, list, map, object など）
- **default** - デフォルト値（オプション）

### datasources.tf

`datasources.tf`ファイルでは、既存のOCIリソースを参照するためのデータソースを定義します：

```hcl
data "oci_identity_availability_domain" "ad" {
  compartment_id = var.tenancy_ocid
  ad_number      = 1
}

data "oci_core_images" "oracle_linux" {
  compartment_id           = var.tenancy_ocid
  operating_system         = "Oracle Linux"
  operating_system_version = "8"
  shape                    = "VM.Standard.A1.Flex"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}
```

データソースは、リソースを作成するのではなく、既存のリソースの情報を取得します：
- **oci_identity_availability_domain** - 可用性ドメインの情報を取得
- **oci_core_images** - 指定した条件に一致するOSイメージを取得

### outputs.tf

`outputs.tf`ファイルでは、Terraformの実行後に表示される出力値を定義します：

```hcl
output "instance_public_ip" {
  description = "インスタンスのパブリックIPアドレス"
  value       = oci_core_instance.tf_instance.public_ip
}
```

出力値は、以下の用途に役立ちます：
- 作成したリソースの重要な情報を表示
- 他のTerraformモジュールへの入力として使用
- CI/CDパイプラインでの参照

## リソースの確認方法

Terraformでリソースをデプロイした後、OCIコンソールで確認できます：

1. [OCIコンソール](https://cloud.oracle.com/)にログイン
2. 左側のハンバーガーメニュー → コンピュート → インスタンス
3. コンパートメント「terraform-compartment」を選択
4. 作成されたインスタンス「TerraformInstance」を確認

インスタンスへのSSH接続：

```bash
ssh opc@<instance_public_ip> -i <private_key_path>
```

## クリーンアップ

使用が終わったら、リソースを削除してください：

```bash
terraform destroy
```

確認メッセージが表示されたら、`yes`と入力します。

## トラブルシューティング

### よくある問題と解決策

1. **認証エラー**
   - APIキーの設定を確認
   - フィンガープリントが正しいか確認
   - 秘密鍵のパスが正しいか確認

2. **サービス制限エラー**
   - Always Freeの制限を超えていないか確認
   - リージョンを変更してみる

3. **リソース作成エラー**
   - エラーメッセージを確認
   - OCIコンソールでリソースの状態を確認

## 発展課題

このハンズオンを完了した後、以下の発展課題に挑戦してみましょう：

1. **Webサーバーのデプロイ**
   - Terraformのプロビジョナーを使用してNginxをインストール
   - セキュリティリストにHTTPポートを追加

2. **モジュール化**
   - コードをモジュールに分割
   - 再利用可能なコンポーネントを作成

3. **リモートステート**
   - Terraformの状態をOCIオブジェクトストレージに保存
   - チーム開発のための設定

4. **自動化パイプライン**
   - GitHub ActionsでTerraformを自動実行
   - プルリクエストでの`plan`と`apply`の自動化

---

このハンズオンが、Terraformを使ったOCIリソースの管理の理解に役立つことを願っています。質問や改善点があれば、Issueを作成してください。

Happy Terraforming!