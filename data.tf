locals {
  default_environment_variables = [
    "DROPLET_INTERNAL_IP=${digitalocean_droplet.default.ipv4_address_private}",
    "DROPLET_EXTERNAL_IP=${digitalocean_droplet.default.ipv4_address}",
  ]

  default_packages = [
    "curl",
    "mc",
    "net-tools"
  ]

  default_commands = [
    "sudo mkdir -p ${var.app_data}/${var.app_configurations}",
    "sudo chown ${var.droplet_user}:terraform ${var.app_data}/${var.app_configurations}",
    "sudo chmod 775 ${var.app_data}/${var.app_configurations}",
  ]

  user_data = <<EOF
#cloud-config

ssh_pwauth: false
disable_root: true
package_update: true
package_upgrade: true
manage_etc_hosts: true

users:
  - name: ${var.droplet_user}
    groups:
      - sudo
    sudo:
      - ALL=(ALL) NOPASSWD:ALL
    ssh-authorized-keys:
      - ${data.digitalocean_ssh_key.user.public_key}
  - name: terraform
    groups:
      - sudo
    sudo:
      - ALL=(ALL) NOPASSWD:ALL
    ssh-authorized-keys:
      - ${data.digitalocean_ssh_key.remote_provisioner.public_key}

packages:
${local.default_packages != null ? join("\n", formatlist("  - '%s'", local.default_packages)) : ""}
${var.os_packages != null ? join("\n", formatlist("  - '%s'", var.os_packages)) : ""}

runcmd:
${local.default_commands != null ? join("\n", formatlist("  - '%s'", local.default_commands)) : ""}
EOF
}

data "digitalocean_ssh_key" "user" {
  name = var.droplet_user
}

data "digitalocean_ssh_key" "remote_provisioner" {
  name = "terraform"
}

data "digitalocean_project" "this" {
  name = var.droplet_project
}

data "digitalocean_domain" "this" {
  name = var.droplet_dns_zone
}

data "digitalocean_vpc" "this" {
  name = "${var.droplet_region}-vpc-${var.droplet_project}"
}

data "digitalocean_droplet_snapshot" "this" {
  name        = var.droplet_image
  region      = var.droplet_region
  most_recent = true
}
