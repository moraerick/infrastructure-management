variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "region" {
  default = "us-ashburn-1"
}

variable "compartment_ocid" {}
variable "ssh_public_key_path" {
  description = "Ruta al archivo de clave pública SSH"
}

variable "instance_shape" {
  default = "VM.Standard.E2.1.Micro"
}

variable "instance_display_name" {
  default = "jenkins-instance"
}

variable "subnet_ocid" {
  description = "The OCID of the subnet to attach the instance to."
  type        = string
}

variable "ssh_public_key" {
  type        = string
  description = "Public SSH key for instance access"
}
