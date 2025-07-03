# OCI Free Tier Terraform Configuration - Outputs

output "instance_public_ip" {
  description = "インスタンスのパブリックIPアドレス"
  value       = oci_core_instance.tf_instance.public_ip
}

output "vcn_id" {
  description = "作成されたVCNのID"
  value       = oci_core_vcn.tf_vcn.id
}

output "compartment_id" {
  description = "作成されたコンパートメントのID"
  value       = oci_identity_compartment.tf_compartment.id
}

output "subnet_id" {
  description = "作成されたサブネットのID"
  value       = oci_core_subnet.tf_public_subnet.id
}

output "block_volume_id" {
  description = "作成されたブロックボリュームのID"
  value       = oci_core_volume.tf_block_volume.id
}