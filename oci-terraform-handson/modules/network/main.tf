# OCI Network Module - Main

# 仮想クラウドネットワーク (VCN) 作成
resource "oci_core_vcn" "vcn" {
  compartment_id = var.compartment_id
  cidr_blocks    = [var.vcn_cidr]
  display_name   = var.vcn_name
  dns_label      = var.vcn_dns_label
}

# インターネットゲートウェイ作成
resource "oci_core_internet_gateway" "internet_gateway" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "${var.vcn_name}-igw"
  enabled        = true
}

# ルートテーブル作成
resource "oci_core_route_table" "route_table" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "${var.vcn_name}-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.internet_gateway.id
  }
}

# パブリックサブネット作成
resource "oci_core_subnet" "public_subnet" {
  compartment_id             = var.compartment_id
  vcn_id                     = oci_core_vcn.vcn.id
  cidr_block                 = var.public_subnet_cidr
  display_name               = "${var.vcn_name}-public-subnet"
  dns_label                  = "public"
  route_table_id             = oci_core_route_table.route_table.id
  security_list_ids          = [oci_core_security_list.security_list.id]
  prohibit_public_ip_on_vnic = false
}

# セキュリティリスト作成
resource "oci_core_security_list" "security_list" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "${var.vcn_name}-security-list"

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