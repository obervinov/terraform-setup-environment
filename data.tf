# Disabled CloudInit APT update and upgrade to avoid error (reproducible on DO Ubuntu 24.04 image. Will be debugged later):
# "Failed to update package using apt: Unexpected error while running command. Command: ['eatmydata', 'apt-get', '--option=Dpkg::Options::=--force-confold', '--option=Dpkg::options::=--force-unsafe-io', '--assume-yes', '--quiet', 'update'] Exit code: 100 Reason: - Stdout: - Stderr: -"
locals {
  # Legacy format of droplet name with region suffix to keep compatibility with existing setups. Will be changed in future releases to just `var.droplet_name`
  droplet_name            = var.droplet_name_override != null ? var.droplet_name_override : "${var.droplet_name}-${var.droplet_region}"
  # Complicated logic to resolve image ID from slug or snapshot name to keep compatibility with existing setups. Will be simplified in future releases to just use `var.droplet_image` (slug or ID).
  # Resolve image ID from slug if image ID is not provided (public or private images)
  snapshot_id             = length(data.digitalocean_droplet_snapshot.this) > 0 ? data.digitalocean_droplet_snapshot.this[0].id : null
  # Directly use provided image ID if available. Snapshot ID if not. Otherwise use default image slug from variable.
  image_id                = var.droplet_image_id != null ? var.droplet_image_id : (local.snapshot_id != null ? local.snapshot_id : var.droplet_image)  

  remote_provisioner_host = var.droplet_provisioner_external_ip ? digitalocean_droplet.this.ipv4_address : digitalocean_droplet.this.ipv4_address_private

  ssh_keys = [
    data.digitalocean_ssh_key.user.id,
    data.digitalocean_ssh_key.remote_provisioner.id
  ]

  default_environment_variables = [
    "DROPLET_INTERNAL_IP=${digitalocean_droplet.this.ipv4_address_private}",
    "DROPLET_EXTERNAL_IP=${digitalocean_droplet.this.ipv4_address}",
  ]

  default_commands = [
    "sudo DEBIAN_FRONTEND=noninteractive apt-get update && sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y",
    "sudo mkdir -p ${var.app_data}/${var.app_configurations}",
    "sudo chown ${var.droplet_user}:${var.droplet_provisioner_ssh_key_name} ${var.app_data}/${var.app_configurations}",
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
  - name: ${var.droplet_provisioner_ssh_key_name}
    groups:
      - sudo
    sudo:
      - ALL=(ALL) NOPASSWD:ALL
    ssh_authorized_keys:
      - ${data.digitalocean_ssh_key.remote_provisioner.public_key}

${var.os_packages != null && length(var.os_packages) > 0 ? "packages:\n" : ""}${var.os_packages != null ? join("\n", formatlist("  - '%s'", var.os_packages)) : ""}

runcmd:
${local.default_commands != null ? join("\n", formatlist("  - '%s'", local.default_commands)) : ""}
EOF
}

data "digitalocean_ssh_key" "user" {
  name = var.droplet_user
}

data "digitalocean_ssh_key" "remote_provisioner" {
  name = var.droplet_provisioner_ssh_key_name
}

data "digitalocean_project" "this" {
  name = var.droplet_project
}

data "digitalocean_domain" "this" {
  count = var.dns_provider == "digitalocean" ? 1 : 0

  name = var.droplet_dns_zone
}

data "digitalocean_vpc" "this" {
  name = "${var.droplet_region}-vpc-${var.droplet_project}"
}

data "digitalocean_droplet_snapshot" "this" {
  count = var.droplet_image_id == null && var.droplet_image != null && var.droplet_image != "" ? 1 : 0

  name        = var.droplet_image
  region      = var.droplet_region
  most_recent = true
}

data "cloudflare_zones" "this" {
  count = var.droplet_dns_record && var.dns_provider == "cloudflare" ? 1 : 0

  name = var.droplet_dns_zone
}

data "cloudflare_zone" "this" {
  count = length(data.cloudflare_zones.this)

  zone_id = length(data.cloudflare_zones.this[count.index].result) > 0 ? data.cloudflare_zones.this[count.index].result[0].id : null
}