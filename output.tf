output "droplet_info" {
  description = "Droplet base info"
  value = {
    id   = digitalocean_droplet.this.id
    name = digitalocean_droplet.this.name
  }
}

output "droplet_networks" {
  description = " Droplet networks addresses"
  value = {
    internal_v4 = digitalocean_droplet.this.ipv4_address_private
    external_v4 = digitalocean_droplet.this.ipv4_address
    reserved_v4 = var.droplet_reserved_ip ? digitalocean_reserved_ip.this[0].ip_address : ""
  }
}

output "droplet_user" {
  description = "Created user for ssh droplet"
  value = {
    name    = var.droplet_user
    ssh_key = data.digitalocean_ssh_key.user.fingerprint
  }
}

output "droplet_dns" {
  description = "Droplet dns record info"
  value = {
    dns_record    = var.droplet_dns_record ? digitalocean_record.this[0].fqdn : ""
    cname_records = join(", ", [for item in var.app_cname_records : "${item}.${data.digitalocean_domain.this.name}"])
  }
}

output "droplet_volume" {
  description = "Droplet additional volume info"
  value = {
    name = var.droplet_volume_size > 0 ? digitalocean_volume.this[0].name : ""
    size = var.droplet_volume_size
  }
}
