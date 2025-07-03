# OCI Compute Module - Main

# Always Free対象のAmpere A1コンピュートインスタンス作成
resource "oci_core_instance" "instance" {
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_id
  display_name        = var.instance_name
  shape               = "VM.Standard.A1.Flex"

  shape_config {
    ocpus         = var.ocpus
    memory_in_gbs = var.memory_in_gbs
  }

  create_vnic_details {
    subnet_id        = var.subnet_id
    assign_public_ip = true
  }

  source_details {
    source_type = "image"
    source_id   = var.image_id
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
  }
}

# ブロックボリューム作成 (Always Free対象の200GB以内)
resource "oci_core_volume" "block_volume" {
  count               = var.block_volume_size_in_gbs > 0 ? 1 : 0
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_id
  display_name        = "${var.instance_name}-block-volume"
  size_in_gbs         = var.block_volume_size_in_gbs
}

# ブロックボリュームのアタッチメント
resource "oci_core_volume_attachment" "volume_attachment" {
  count           = var.block_volume_size_in_gbs > 0 ? 1 : 0
  attachment_type = "paravirtualized"
  instance_id     = oci_core_instance.instance.id
  volume_id       = oci_core_volume.block_volume[0].id
}