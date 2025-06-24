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
  description = "Droplet DNS record info for DigitalOcean provider, if applicable."
  value = {
    # Determines whether to include DNS record information in the output. This condition
    # typically depends on whether DNS records are configured for the droplet.
    dns_record = local.dns_record_condition ? try(digitalocean_record.this[0].fqdn, "") : ""
    cname_records = (
      length(var.app_cname_records) > 0 &&
      local.dns_record_condition &&
      length(data.digitalocean_domain.this) > 0
    ) ? join(", ", [for item in var.app_cname_records : "${item}.${data.digitalocean_domain.this[0].name}"]) : ""
  }
}

output "droplet_volume" {
  description = "Droplet additional volume info"
  value = {
    name = var.droplet_volume_size > 0 ? digitalocean_volume.this[0].name : ""
    size = var.droplet_volume_size
  }
}
