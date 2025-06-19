resource "digitalocean_record" "this" {
  count = var.droplet_dns_record && var.dns_provider == "digitalocean" ? 1 : 0

  domain = var.droplet_dns_record ? data.digitalocean_domain.this[0].id : null
  type   = "A"
  name   = var.droplet_name
  value  = var.droplet_reserved_ip ? digitalocean_reserved_ip.this[0].ip_address : digitalocean_droplet.this.ipv4_address
}

resource "digitalocean_record" "additional" {
  depends_on = [digitalocean_record.this]

  for_each = length(var.app_cname_records) > 0 && var.droplet_dns_record && var.dns_provider == "digitalocean" ? toset(var.app_cname_records) : toset([])

  domain = data.digitalocean_domain.this[0].id
  type   = "CNAME"
  name   = each.value
  value  = length(digitalocean_record.this) > 0 ? "${digitalocean_record.this[0].fqdn}." : null
}

resource "cloudflare_dns_record" "this" {
  count = var.droplet_dns_record && var.dns_provider == "cloudflare" ? 1 : 0

  zone_id = data.cloudflare_zone.this[count.index].zone_id
  name    = "${var.droplet_name}.${data.cloudflare_zone.this[count.index].name}"
  type    = "A"
  comment = "A record for the DigitalOcean droplet ${var.droplet_name}"
  content = var.droplet_reserved_ip ? digitalocean_reserved_ip.this[0].ip_address : digitalocean_droplet.this.ipv4_address
  proxied = var.cloudflare_dns_settings.proxied
  ttl     = var.cloudflare_dns_settings.proxied ? 1 : var.cloudflare_dns_settings.ttl
}

data "cloudflare_dns_record" "this" {
  depends_on = [cloudflare_dns_record.this]

  count = var.droplet_dns_record && var.dns_provider == "cloudflare" ? 1 : 0

  dns_record_id = cloudflare_dns_record.this[count.index].id
  zone_id       = data.cloudflare_zone.this[count.index].zone_id
  name          = "${var.droplet_name}.${data.cloudflare_zone.this[count.index].name}"
  type          = "A"
}

resource "cloudflare_dns_record" "additional" {
  depends_on = [cloudflare_dns_record.this]

  for_each = length(var.app_cname_records) > 0 && var.droplet_dns_record && var.dns_provider == "cloudflare" ? toset(var.app_cname_records) : toset([])

  zone_id = data.cloudflare_zone.this[0].zone_id
  name    = each.value
  type    = "CNAME"
  comment = "CNAME record for the DigitalOcean droplet ${var.droplet_name}"
  content = length(cloudflare_dns_record.this) > 0 ? "${data.cloudflare_dns_record.this[0].name}." : null
  proxied = var.cloudflare_dns_settings.proxied
  ttl     = var.cloudflare_dns_settings.proxied ? 1 : var.cloudflare_dns_settings.ttl
}
