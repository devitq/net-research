terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
    }
  }
}

locals {
  dot_env_file_path = ".env"
  dot_env_regex     = "(?m:^\\s*([^#\\s]\\S*)\\s*=\\s*[\"']?(.*[^\"'\\s])[\"']?\\s*$)"
  dot_env           = { for tuple in regexall(local.dot_env_regex, file(local.dot_env_file_path)) : tuple[0] => sensitive(tuple[1]) }

  uri               = local.dot_env["LIBVIRT_DEFAULT_URI"]
  image_pool_folder = local.dot_env["IMAGE_POOL_FOLDER"] # не то же самое что libvirt_pool

  image_filename = "noble-server-cloudimg-amd64.img" # да, можно было и ссылку, но я не хочу, чтобы кто-то качал его

  client_ip    = "10.6.6.10"
  server_ip    = "10.6.6.20"
  network_cidr = "10.6.6.0/24"
  mtu          = 1500

  cpu_per_node = 4
  mem_per_node = "2048"
}

provider "libvirt" {
  uri = local.uri
}

resource "libvirt_network" "default" {
  name = "task5_default"

  mode      = "nat"
  addresses = [local.network_cidr]
  mtu       = local.mtu
  autostart = true

  dns {
    local_only = false

    forwarders {
      address = "1.1.1.1"
    }

    hosts {
      hostname = "client"
      ip       = local.client_ip
    }
    hosts {
      hostname = "server"
      ip       = local.server_ip
    }
  }
}

resource "libvirt_volume" "ubuntu_noble" {
  name   = "task5_ubuntu_noble"
  source = "${local.image_pool_folder}/${local.image_filename}"
}

resource "libvirt_volume" "client_image" {
  name           = "task5_client_image"
  base_volume_id = libvirt_volume.ubuntu_noble.id
}

resource "libvirt_volume" "server_image" {
  name           = "task5_server_image"
  base_volume_id = libvirt_volume.ubuntu_noble.id
}

data "template_file" "client_user_data" {
  template = file("${path.module}/configs/cloud-init/client.yaml.tpl")
  vars = {
    hosts_file            = base64encode(file("${path.module}/configs/hosts"))
  }
}

data "template_file" "server_user_data" {
  template = file("${path.module}/configs/cloud-init/server.yaml.tpl")
  vars = {
    nginx_conf = base64encode(file("${path.module}/configs/nginx/nginx.conf"))
    tftpd_conf = base64encode(file("${path.module}/configs/tftpd/tftpd-hpa"))
    caddy_conf = base64encode(file("${path.module}/configs/caddy/Caddyfile"))
    hosts_file = base64encode(file("${path.module}/configs/hosts"))
  }
}

module "client" {
  source         = "./modules/instance"
  name           = "task5_client"
  network_id     = libvirt_network.default.id
  ip             = local.client_ip
  volume_base_id = libvirt_volume.ubuntu_noble.id
  user_data      = data.template_file.client_user_data.rendered
  vcpu           = local.cpu_per_node
  memory         = local.mem_per_node
}

module "server" {
  source         = "./modules/instance"
  name           = "task5_server"
  network_id     = libvirt_network.default.id
  ip             = local.server_ip
  volume_base_id = libvirt_volume.ubuntu_noble.id
  user_data      = data.template_file.server_user_data.rendered
  vcpu           = local.cpu_per_node
  memory         = local.mem_per_node
}
