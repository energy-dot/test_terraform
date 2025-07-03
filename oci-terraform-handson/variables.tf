# OCI Free Tier Terraform Configuration - Variables

variable "tenancy_ocid" {
  description = "OCIテナンシーのOCID"
  type        = string
}

variable "user_ocid" {
  description = "OCIユーザーのOCID"
  type        = string
}

variable "fingerprint" {
  description = "APIキーのフィンガープリント"
  type        = string
}

variable "private_key_path" {
  description = "APIキーの秘密鍵のパス"
  type        = string
}

variable "region" {
  description = "OCIリージョン"
  type        = string
  default     = "ap-tokyo-1"
}

variable "ssh_public_key" {
  description = "インスタンスへのSSH接続に使用する公開鍵"
  type        = string
}