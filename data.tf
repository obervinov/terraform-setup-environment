# Disabled CloudInit APT update and upgrade to avoid error
# "Failed to update package using apt: Unexpected error while running command. Command: ['eatmydata', 'apt-get', '--option=Dpkg::Options::=--force-confold', '--option=Dpkg::options::=--force-unsafe-io', '--assume-yes', '--quiet', 'update'] Exit code: 100 Reason: - Stdout: - Stderr: -"
locals {
  remote_provisioner_host = var.droplet_provisioner_external_ip ? digitalocean_droplet.this.ipv4_address : digitalocean_droplet.this.ipv4_address_private
  default_environment_variables = [
    "DROPLET_INTERNAL_IP=${digitalocean_droplet.this.ipv4_address_private}",
    "DROPLET_EXTERNAL_IP=${digitalocean_droplet.this.ipv4_address}",
  ]
  default_commands = [
    "sudo DEBIAN_FRONTEND=noninteractive apt-get update && sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y",
    "sudo mkdir -p ${var.app_data}/${var.app_configurations}",
    "sudo chown ${var.droplet_user}:terraform ${var.app_data}/${var.app_configurations}",
    "sudo chmod 775 ${var.app_data}/${var.app_configurations}",
  ]
  user_data = <<EOF
#cloud-config

ssh_pwauth: false
disable_root: true
package_update: false
package_upgrade: false
manage_etc_hosts: true

users:
  - name: ${var.droplet_user}
    groups:
      - sudo
    sudo:
      - ALL=(ALL) NOPASSWD:ALL
    ssh_authorized_keys:
      - ${data.digitalocean_ssh_key.user.public_key}
  - name: terraform
    groups:
      - sudo
    sudo:
      - ALL=(ALL) NOPASSWD:ALL
    ssh_authorized_keys:
      - ${data.digitalocean_ssh_key.remote_provisioner.public_key}

${local.packages_block}

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
  count = var.dns_provider == "digitalocean" ? 1 : 0
  name  = var.droplet_dns_zone
}

data "digitalocean_vpc" "this" {
  name = "${var.droplet_region}-vpc-${var.droplet_project}"
}

data "digitalocean_droplet_snapshot" "this" {
  name        = var.droplet_image
  region      = var.droplet_region
  most_recent = true
}

data "cloudflare_zones" "this" {
  count = var.droplet_dns_record && var.dns_provider == "cloudflare" ? 1 : 0
  name  = var.droplet_dns_zone
}

data "cloudflare_zone" "this" {
  count   = length(data.cloudflare_zones.this)
  zone_id = length(data.cloudflare_zones.this[count.index].result) > 0 ? data.cloudflare_zones.this[count.index].result[0].id : null
}