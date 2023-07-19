output "droplet_name" {
  description = "Droplet name"
  value       = digitalocean_droplet.droplet.name
}

output "droplet_external_ip" {
  description = "Droplet external ip-address"
  value       = digitalocean_droplet.droplet.ipv4_address
}

output "droplet_username" {
  description = "Username for new user"
  value       = var.username
}

output "droplet_ssh_key_fingerprint" {
  description = "SSH Key fingerprint"
  value       = data.digitalocean_ssh_key.key.fingerprint
}

output "droplet_dns_record" {
  description = "Dns record for new droplet"
  value       = var.droplet_dns_record ? data.digitalocean_domain.domain[0].name : ""
}

output "droplet_reserved_ip" {
  description = "Reserved ip for new droplet"
  value       = var.droplet_reserved_ip ? digitalocean_reserved_ip.ip[0].ip_address : ""
}
