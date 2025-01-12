# Provising resources in DigitalOcean
# Droplet, reserved IP, DNS record, volume, volume snapshot
resource "digitalocean_droplet" "this" {
  name          = "${var.droplet_name}-${var.droplet_region}"
  image         = data.digitalocean_droplet_snapshot.this.id
  region        = var.droplet_region
  size          = var.droplet_size
  backups       = var.droplet_backups
  monitoring    = var.droplet_do_monitoring
  droplet_agent = var.droplet_do_agent
  vpc_uuid      = data.digitalocean_vpc.this.id
  tags          = var.droplet_tags
  user_data     = local.user_data
  ssh_keys = [
    data.digitalocean_ssh_key.user.id,
    data.digitalocean_ssh_key.remote_provisioner.id
  ]
}

resource "digitalocean_project_resources" "this" {
  depends_on = [digitalocean_droplet.this]

  project = data.digitalocean_project.this.id
  resources = [digitalocean_droplet.this.urn]
}

resource "digitalocean_reserved_ip" "this" {
  count = var.droplet_reserved_ip ? 1 : 0

  droplet_id = digitalocean_droplet.this.id
  region     = digitalocean_droplet.this.region
}

resource "digitalocean_record" "this" {
  count = var.droplet_dns_record ? 1 : 0

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

resource "digitalocean_volume" "this" {
  count = var.droplet_volume_size > 0 ? 1 : 0

  region                  = digitalocean_droplet.this.region
  name                    = "${var.droplet_name}-${var.droplet_region}-volume"
  size                    = var.droplet_volume_size
  initial_filesystem_type = "ext4"
  description             = "Additional volume for ${digitalocean_droplet.this.name}"
}

resource "digitalocean_volume_attachment" "this" {
  depends_on = [digitalocean_volume.this]

  count = var.droplet_volume_size > 0 ? 1 : 0

  droplet_id = digitalocean_droplet.this.id
  volume_id  = digitalocean_volume.this[count.index].id
}

resource "digitalocean_volume_snapshot" "this" {
  count = var.droplet_volume_size > 0 ? 1 : 0

  name      = "${var.droplet_name}--${var.droplet_region}-volume-snapshot"
  volume_id = digitalocean_volume.this[count.index].id
}
