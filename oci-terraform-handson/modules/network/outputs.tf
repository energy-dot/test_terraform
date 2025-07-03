# OCI Network Module - Outputs

output "vcn_id" {
  description = "作成されたVCNのID"
  value       = oci_core_vcn.vcn.id
}

output "subnet_id" {
  description = "作成されたパブリックサブネットのID"
  value       = oci_core_subnet.public_subnet.id
}

output "security_list_id" {
  description = "作成されたセキュリティリストのID"
  value       = oci_core_security_list.security_list.id
}

output "internet_gateway_id" {
  description = "作成されたインターネットゲートウェイのID"
  value       = oci_core_internet_gateway.internet_gateway.id
}

output "route_table_id" {
  description = "作成されたルートテーブルのID"
  value       = oci_core_route_table.route_table.id
}