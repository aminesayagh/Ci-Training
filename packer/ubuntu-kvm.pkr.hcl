# packer/ubuntu-kvm.pkr.hcl

# Variables
variable "ubuntu_version" {
  type    = string
  default = "24.04"
}

variable "cpu_count" {
  type    = number
  default = 2
}

variable "memory" {
  type    = number
  default = 2048
}

variable "disk_size" {
  type    = string
  default = "20G"
}

variable "cpu_count" {
  type    = number
  default = 2
}

variable "memory" {
  type    = number
  default = 2048
}

variable "disk_size" {
  type    = string
  default = "20G"
}

# Source block for Ubuntu KVM
source "qemu" "ubuntu" {
  iso_url          = "https://releases.ubuntu.com/${var.ubuntu_version}/ubuntu-${var.ubuntu_version}-live-server-amd64.iso"
  iso_checksum     = "file:https://releases.ubuntu.com/${var.ubuntu_version}/SHA256SUMS"
  output_directory = "output-ubuntu-${var.ubuntu_version}"
  shutdown_command = "echo 'packer' | sudo -S shutdown -P now"
  disk_size        = var.disk_size
  format           = "qcow2"
  accelerator      = "kvm"
  http_directory   = "http"
  ssh_username     = var.ssh_username
  ssh_private_key_file = var.ssh_private_key_file
  ssh_timeout      = "20m"
  vm_name          = "ubuntu-${var.ubuntu_version}.qcow2"
  memory           = var.memory
  cpus             = var.cpu_count
  headless         = true

  boot_command = [
    "<esc><wait>",
    "e<wait>",
    "<down><down><down><end>",
    " autoinstall ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/",
    "<f10>"
  ]
}

# Build block
build {
  sources = ["source.qemu.ubuntu"]

  # Copy cloud-init configurations
  provisioner "file" {
    source      = "cloud-init/templates"
    destination = "/tmp/"
  }

  # Run setup scripts
  provisioner "shell" {
    scripts = [
      "scripts/setup.sh",
      "scripts/cleanup.sh"
    ]
  }
}