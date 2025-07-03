# OCI Compute Module - Outputs

output "instance_id" {
  description = "作成されたインスタンスのID"
  value       = oci_core_instance.instance.id
}

output "instance_public_ip" {
  description = "インスタンスのパブリックIPアドレス"
  value       = oci_core_instance.instance.public_ip
}

output "instance_private_ip" {
  description = "インスタンスのプライベートIPアドレス"
  value       = oci_core_instance.instance.private_ip
}

output "block_volume_id" {
  description = "作成されたブロックボリュームのID"
  value       = var.block_volume_size_in_gbs > 0 ? oci_core_volume.block_volume[0].id : null
}