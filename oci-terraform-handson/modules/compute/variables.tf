# OCI Compute Module - Variables

variable "compartment_id" {
  description = "コンパートメントのOCID"
  type        = string
}

variable "availability_domain" {
  description = "可用性ドメイン名"
  type        = string
}

variable "subnet_id" {
  description = "サブネットのOCID"
  type        = string
}

variable "image_id" {
  description = "インスタンスのイメージID"
  type        = string
}

variable "instance_name" {
  description = "インスタンスの名前"
  type        = string
  default     = "TerraformInstance"
}

variable "ocpus" {
  description = "OCPUの数"
  type        = number
  default     = 4
  
  validation {
    condition     = var.ocpus <= 4
    error_message = "OCPUの数はAlways Free枠では最大4です。"
  }
}

variable "memory_in_gbs" {
  description = "メモリ量（GB）"
  type        = number
  default     = 24
  
  validation {
    condition     = var.memory_in_gbs <= 24
    error_message = "メモリ量はAlways Free枠では最大24GBです。"
  }
}

variable "ssh_public_key" {
  description = "インスタンスへのSSH接続に使用する公開鍵"
  type        = string
}

variable "block_volume_size_in_gbs" {
  description = "ブロックボリュームのサイズ（GB）。0の場合は作成しない。"
  type        = number
  default     = 100
  
  validation {
    condition     = var.block_volume_size_in_gbs <= 200
    error_message = "ブロックボリュームのサイズはAlways Free枠では最大200GBです（ブートボリュームを含む）。"
  }
}