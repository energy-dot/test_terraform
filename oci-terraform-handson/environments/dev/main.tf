# OCI Free Tier Terraform Configuration - Development Environment

# Terraform設定ブロック
terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.0.0"
}

# プロバイダー設定
provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}

# コンパートメント作成
resource "oci_identity_compartment" "tf_compartment" {
  name           = "terraform-compartment-dev"
  description    = "Compartment for Terraform resources (Development)"
  compartment_id = var.tenancy_ocid
  
  # フリーティアでは削除時に物理的に削除する
  enable_delete = true
}

# 可用性ドメインの取得
data "oci_identity_availability_domain" "ad" {
  compartment_id = var.tenancy_ocid
  ad_number      = 1
}

# Oracle Linux イメージの取得
data "oci_core_images" "oracle_linux" {
  compartment_id           = var.tenancy_ocid
  operating_system         = "Oracle Linux"
  operating_system_version = "8"
  shape                    = "VM.Standard.A1.Flex"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

# ネットワークモジュールの呼び出し
module "network" {
  source = "../../modules/network"

  compartment_id     = oci_identity_compartment.tf_compartment.id
  vcn_cidr           = "10.0.0.0/16"
  vcn_name           = "DevVCN"
  vcn_dns_label      = "devvcn"
  public_subnet_cidr = "10.0.1.0/24"
}

# コンピュートモジュールの呼び出し
module "compute" {
  source = "../../modules/compute"

  compartment_id         = oci_identity_compartment.tf_compartment.id
  availability_domain    = data.oci_identity_availability_domain.ad.name
  subnet_id              = module.network.subnet_id
  image_id               = data.oci_core_images.oracle_linux.images[0].id
  instance_name          = "DevInstance"
  ocpus                  = 4
  memory_in_gbs          = 24
  ssh_public_key         = var.ssh_public_key
  block_volume_size_in_gbs = 100
}