resource "digitalocean_record" "this" {
  count = var.droplet_dns_record && var.dns_provider == "digitalocean" ? 1 : 0

  domain = var.droplet_dns_record ? element(data.digitalocean_domain.this.*.id, 0) : null
  type   = "A"
  name   = var.droplet_name
  value  = var.droplet_reserved_ip ? digitalocean_reserved_ip.this[0].ip_address : digitalocean_droplet.this.ipv4_address
}

resource "digitalocean_record" "additional" {
  depends_on = [digitalocean_record.this]

  for_each = length(var.app_cname_records) > 0 ? toset(var.app_cname_records) : toset([])

  domain = element(data.digitalocean_domain.this.*.id, 0)
  type   = "CNAME"
  name   = each.value
  value  = length(digitalocean_record.this) > 0 ? "${digitalocean_record.this[0].fqdn}." : null
}

resource "cloudflare_dns_record" "this" {
  count = var.droplet_dns_record && var.dns_provider == "cloudflare" ? 1 : 0

  zone_id = data.cloudflare_zone.this.zone_id
  name    = "${var.droplet_name}.${data.cloudflare_zone.this.name}"
  type    = "A"
  comment = "A record for the DigitalOcean droplet ${var.droplet_name}"
  content = var.droplet_reserved_ip ? digitalocean_reserved_ip.this[0].ip_address : digitalocean_droplet.this.ipv4_address
  proxied = var.cloudflare_dns_settings.proxied
  settings = {
    ipv4_only = var.cloudflare_dns_settings.ipv4_only
    ipv6_only = var.cloudflare_dns_settings.ipv6_only
  }
  tags = ["digitalocean:droplet", var.droplet_name, "terraform-setup-environment"]
  ttl  = var.cloudflare_dns_settings.ttl
}

resource "cloudflare_dns_record" "additional" {
  depends_on = [digitalocean_record.this]

  for_each = length(var.app_cname_records) > 0 ? toset(var.app_cname_records) : toset([])

  zone_id = data.cloudflare_zone.this.zone_id
  name    = "${each.value}.${data.cloudflare_zone.this.name}"
  type    = "CNAME"
  comment = "CNAME record for the DigitalOcean droplet ${var.droplet_name}"
  content = length(digitalocean_record.this) > 0 ? "${digitalocean_record.this[0].fqdn}." : null
  proxied = var.cloudflare_dns_settings.proxied
  settings = {
    ipv4_only = var.cloudflare_dns_settings.ipv4_only
    ipv6_only = var.cloudflare_dns_settings.ipv6_only
  }
  tags = ["digitalocean:droplet", var.droplet_name, "terraform-setup-environment"]
  ttl  = var.cloudflare_dns_settings.ttl
}
