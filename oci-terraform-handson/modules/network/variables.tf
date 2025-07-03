# OCI Network Module - Variables

variable "compartment_id" {
  description = "コンパートメントのOCID"
  type        = string
}

variable "vcn_cidr" {
  description = "VCNのCIDRブロック"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vcn_name" {
  description = "VCNの名前"
  type        = string
  default     = "TerraformVCN"
}

variable "vcn_dns_label" {
  description = "VCNのDNSラベル"
  type        = string
  default     = "tfvcn"
}

variable "public_subnet_cidr" {
  description = "パブリックサブネットのCIDRブロック"
  type        = string
  default     = "10.0.1.0/24"
}