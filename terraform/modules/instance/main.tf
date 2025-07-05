terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
    }
  }
}

variable "name" {}
variable "network_id" {}
variable "ip" {}
variable "volume_base_id" {}
variable "user_data" {}
variable "vcpu" {}
variable "memory" {}

resource "libvirt_volume" "image" {
  name           = "${var.name}_image"
  base_volume_id = var.volume_base_id
}

resource "libvirt_cloudinit_disk" "init" {
  name      = "${var.name}_cloudinit"
  user_data = var.user_data
}

resource "libvirt_domain" "this" {
  name   = var.name
  vcpu   = var.vcpu
  memory = var.memory

  cpu { mode = "host-passthrough" }

  disk { volume_id = libvirt_volume.image.id }
  cloudinit = libvirt_cloudinit_disk.init.id

  network_interface {
    network_id = var.network_id
    addresses  = [var.ip]
  }

  arch    = "x86_64"
  type    = "kvm"
  machine = "q35"

  running   = true
  autostart = false

  xml { xslt = file("${path.root}/configs/libvirt/patch.xsl") }
}
