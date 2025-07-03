# OCI Free Tier Terraform Configuration - Main File

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
  name           = "terraform-compartment"
  description    = "Compartment for Terraform resources"
  compartment_id = var.tenancy_ocid
  
  # フリーティアでは削除時に物理的に削除する
  enable_delete = true
}

# 仮想クラウドネットワーク (VCN) 作成
resource "oci_core_vcn" "tf_vcn" {
  compartment_id = oci_identity_compartment.tf_compartment.id
  cidr_blocks    = ["10.0.0.0/16"]
  display_name   = "TerraformVCN"
  dns_label      = "tfvcn"
}

# インターネットゲートウェイ作成
resource "oci_core_internet_gateway" "tf_internet_gateway" {
  compartment_id = oci_identity_compartment.tf_compartment.id
  vcn_id         = oci_core_vcn.tf_vcn.id
  display_name   = "TerraformInternetGateway"
  enabled        = true
}

# ルートテーブル作成
resource "oci_core_route_table" "tf_route_table" {
  compartment_id = oci_identity_compartment.tf_compartment.id
  vcn_id         = oci_core_vcn.tf_vcn.id
  display_name   = "TerraformRouteTable"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.tf_internet_gateway.id
  }
}

# パブリックサブネット作成
resource "oci_core_subnet" "tf_public_subnet" {
  compartment_id             = oci_identity_compartment.tf_compartment.id
  vcn_id                     = oci_core_vcn.tf_vcn.id
  cidr_block                 = "10.0.1.0/24"
  display_name               = "TerraformPublicSubnet"
  dns_label                  = "public"
  route_table_id             = oci_core_route_table.tf_route_table.id
  security_list_ids          = [oci_core_security_list.tf_security_list.id]
  prohibit_public_ip_on_vnic = false
}

# セキュリティリスト作成
resource "oci_core_security_list" "tf_security_list" {
  compartment_id = oci_identity_compartment.tf_compartment.id
  vcn_id         = oci_core_vcn.tf_vcn.id
  display_name   = "TerraformSecurityList"

  # SSH接続用のインバウンドルール
  ingress_security_rules {
    protocol  = "6" # TCP
    source    = "0.0.0.0/0"
    stateless = false

    tcp_options {
      min = 22
      max = 22
    }
  }

  # HTTP接続用のインバウンドルール
  ingress_security_rules {
    protocol  = "6" # TCP
    source    = "0.0.0.0/0"
    stateless = false

    tcp_options {
      min = 80
      max = 80
    }
  }

  # HTTPS接続用のインバウンドルール
  ingress_security_rules {
    protocol  = "6" # TCP
    source    = "0.0.0.0/0"
    stateless = false

    tcp_options {
      min = 443
      max = 443
    }
  }

  # すべてのアウトバウンドトラフィックを許可
  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
    stateless   = false
  }
}

# Always Free対象のAmpere A1コンピュートインスタンス作成
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

# ブロックボリューム作成 (Always Free対象の200GB以内)
resource "oci_core_volume" "tf_block_volume" {
  availability_domain = data.oci_identity_availability_domain.ad.name
  compartment_id      = oci_identity_compartment.tf_compartment.id
  display_name        = "TerraformBlockVolume"
  size_in_gbs         = 100
}

# ブロックボリュームのアタッチメント
resource "oci_core_volume_attachment" "tf_volume_attachment" {
  attachment_type = "paravirtualized"
  instance_id     = oci_core_instance.tf_instance.id
  volume_id       = oci_core_volume.tf_block_volume.id
}