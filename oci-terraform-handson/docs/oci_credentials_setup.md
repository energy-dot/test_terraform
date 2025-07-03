# OCI認証情報のセットアップガイド

このガイドでは、Oracle Cloud Infrastructure (OCI) でTerraformを使用するために必要な認証情報のセットアップ方法を説明します。

## 目次

1. [OCIアカウントの作成](#ociアカウントの作成)
2. [APIキーの作成](#apiキーの作成)
3. [必要な情報の収集](#必要な情報の収集)
4. [Terraformの設定](#terraformの設定)
5. [トラブルシューティング](#トラブルシューティング)

## OCIアカウントの作成

まだOCIアカウントをお持ちでない場合は、以下の手順で作成してください：

1. [OCI Free Tier登録ページ](https://www.oracle.com/cloud/free/)にアクセス
2. 「無料アカウントを開始」ボタンをクリック
3. 必要な情報を入力し、アカウントを作成
4. メールアドレスの確認
5. クレジットカード情報の入力（検証のみに使用され、課金はされません）
6. アカウント作成完了

## APIキーの作成

Terraformを使用してOCIリソースを管理するには、APIキーが必要です：

### 1. OCIコンソールにログイン

[OCIコンソール](https://cloud.oracle.com/)にアクセスし、作成したアカウントでログインします。

### 2. ユーザー設定画面に移動

右上のプロファイルアイコンをクリックし、「ユーザー設定」を選択します。

![ユーザー設定](https://docs.oracle.com/ja-jp/iaas/Content/Resources/Images/console_profile_menu.png)

### 3. APIキーの追加

1. 左側のメニューから「APIキー」を選択
2. 「APIキーの追加」ボタンをクリック

![APIキーの追加](https://docs.oracle.com/ja-jp/iaas/Content/Resources/Images/console_add_api_key.png)

### 4. キーペアの生成

以下のいずれかの方法でキーペアを生成します：

#### 方法1: OCIコンソールで生成

1. 「キーペアの生成」を選択
2. 「秘密キーのダウンロード」をクリック
3. 「公開キーのダウンロード」をクリック
4. 「追加」ボタンをクリック

#### 方法2: 手動で生成（Linux/Mac）

ターミナルで以下のコマンドを実行します：

```bash
# ディレクトリの作成
mkdir -p ~/.oci

# 秘密鍵の生成
openssl genrsa -out ~/.oci/oci_api_key.pem 2048

# 権限の設定
chmod 600 ~/.oci/oci_api_key.pem

# 公開鍵の生成
openssl rsa -pubout -in ~/.oci/oci_api_key.pem -out ~/.oci/oci_api_key_public.pem
```

生成した公開鍵（`oci_api_key_public.pem`）の内容をコピーし、OCIコンソールの「公開キーの貼り付け」欄に貼り付けて「追加」ボタンをクリックします。

## 必要な情報の収集

Terraformの設定に必要な情報を収集します：

### 1. テナンシーOCID

1. OCIコンソールのメニューから「管理」→「テナンシーの詳細」を選択
2. 「テナンシー情報」セクションの「OCID」をコピー

![テナンシーOCID](https://docs.oracle.com/ja-jp/iaas/Content/Resources/Images/console_tenancy_ocid.png)

### 2. ユーザーOCID

1. 右上のプロファイルアイコンをクリックし、「ユーザー設定」を選択
2. 「ユーザー情報」セクションの「OCID」をコピー

### 3. フィンガープリント

APIキーを追加した後、「APIキー」セクションに表示されるフィンガープリントをコピーします。

### 4. リージョン識別子

現在のリージョンは、コンソールの右上に表示されています。リージョン識別子（例：`ap-tokyo-1`）をメモします。

リージョン識別子の一覧は[OCIドキュメント](https://docs.oracle.com/ja-jp/iaas/Content/General/Concepts/regions.htm)で確認できます。

## Terraformの設定

収集した情報を使用して、Terraformの設定を行います：

### 1. terraform.tfvarsファイルの作成

```bash
cp terraform.tfvars.example terraform.tfvars
```

### 2. 認証情報の設定

エディタで`terraform.tfvars`ファイルを開き、収集した情報を入力します：

```hcl
tenancy_ocid     = "ocid1.tenancy.oc1..xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
user_ocid        = "ocid1.user.oc1..xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
fingerprint      = "xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx"
private_key_path = "~/.oci/oci_api_key.pem"
region           = "ap-tokyo-1"
ssh_public_key   = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQ..."
```

### 3. SSH公開鍵の設定

コンピュートインスタンスへのSSH接続に使用する公開鍵を設定します。既存の鍵を使用するか、新しい鍵を生成します：

```bash
# 新しいSSH鍵ペアの生成
ssh-keygen -t rsa -b 2048 -f ~/.ssh/oci

# 公開鍵の内容を表示
cat ~/.ssh/oci.pub
```

表示された公開鍵の内容を`terraform.tfvars`ファイルの`ssh_public_key`に設定します。

## トラブルシューティング

### APIキーの制限

OCIでは、ユーザーごとに最大3つのAPIキーを登録できます。制限に達した場合は、不要なキーを削除してください。

### 認証エラー

認証エラーが発生した場合は、以下を確認してください：

1. OCIDが正しいか
2. フィンガープリントが正しいか
3. 秘密鍵のパスが正しいか
4. 秘密鍵のパーミッションが適切か（600）

### リージョンエラー

リージョン識別子が正しいことを確認してください。例：`ap-tokyo-1`, `us-ashburn-1`

### その他のエラー

詳細なエラーメッセージを確認するには、環境変数を設定してTerraformを実行します：

```bash
export TF_LOG=DEBUG
terraform apply
```

---

これで、OCIでTerraformを使用するための認証情報のセットアップは完了です。問題が解決しない場合は、[OCIドキュメント](https://docs.oracle.com/ja-jp/iaas/Content/API/SDKDocs/terraformproviderconfiguration.htm)を参照するか、サポートにお問い合わせください。