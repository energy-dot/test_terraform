# OCI Free Tier Terraform Configuration - Outputs

output "compartment_id" {
  description = "作成されたコンパートメントのID"
  value       = oci_identity_compartment.tf_compartment.id
}

output "vcn_id" {
  description = "作成されたVCNのID"
  value       = module.network.vcn_id
}

output "subnet_id" {
  description = "作成されたサブネットのID"
  value       = module.network.subnet_id
}

output "instance_public_ip" {
  description = "インスタンスのパブリックIPアドレス"
  value       = module.compute.instance_public_ip
}

output "block_volume_id" {
  description = "作成されたブロックボリュームのID"
  value       = module.compute.block_volume_id
}