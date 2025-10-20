# Get available availability domains in the tenancy
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

# Get the latest Ubuntu 22.04 image for AMD64 (E2.1.Micro supports AMD)
data "oci_core_images" "ubuntu" {
  compartment_id           = var.tenancy_ocid
  operating_system         = "Canonical Ubuntu"
  operating_system_version = "22.04"
  shape                    = "VM.Standard.E2.1.Micro"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

resource "oci_core_instance" "jenkins" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[1].name
  compartment_id      = var.compartment_ocid
  display_name        = var.instance_display_name
  shape               = var.instance_shape  # VM.Standard.E2.1.Micro

  shape_config {
    ocpus         = 1
    memory_in_gbs = 1
  }

  create_vnic_details {
    assign_public_ip = true
    subnet_id        = var.subnet_ocid
    display_name     = "jenkins-vnic"
    hostname_label   = "jenkins"
  }

  metadata = {
    ssh_authorized_keys = trimspace(file(var.ssh_public_key_path))
    #user_data           = base64encode(file("${path.module}/scripts/install_jenkins.sh"))
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ubuntu.images[0].id
  }

  preserve_boot_volume = false
}
