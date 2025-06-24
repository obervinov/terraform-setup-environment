# Terraform Setup Environment
This module creates a droplet in DigitalOcean with the specified configurations and for the specified role.

## Usage
Module example:
```hcl
locals {
  os_environment_variables = [
    "HAPROXY_VERSION=2.6.2"
  ]
  os_commands = [
    "sudo docker compose -f /opt/configurations/docker-compose.yml up -d --force-recreate --remove-orphans"
  ]
}

module "proxy_server" {
  source  = "app.terraform.io/<ORG_NAME>/environment/setup"
  version = "1.0.0"

  droplet_image               = "ubuntu-1vcpu-512mb"
  droplet_size                = "s-1vcpu-512mb-10gb"
  droplet_user                = "ubuntu"
  droplet_provisioner_ssh_key = "remote-provisioner-ssh-key-name"
  droplet_name                = "proxy-server"
  droplet_tags                = ["ubuntu", "proxy"]
  droplet_project             = "project-name"
  droplet_dns_zone            = "example.com"
  droplet_reserved_ip         = true
  os_environment_variables    = local.os_environment_variables
  os_commands                 = local.os_commands
  os_swap_size                = "2"
  dns_provider                = "digitalocean"
}
```
All files in the `configurations` directory will be copied to the `/opt/configurations` directory on the created server.


## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.11 |
| <a name="requirement_cloudflare"></a> [cloudflare](#requirement\_cloudflare) | >= 5 |
| <a name="requirement_digitalocean"></a> [digitalocean](#requirement\_digitalocean) | >= 2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_cloudflare"></a> [cloudflare](#provider\_cloudflare) | >= 5 |
| <a name="provider_digitalocean"></a> [digitalocean](#provider\_digitalocean) | >= 2 |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [cloudflare_dns_record.additional](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/dns_record) | resource |
| [cloudflare_dns_record.this](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/dns_record) | resource |
| [digitalocean_droplet.this](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/droplet) | resource |
| [digitalocean_project_resources.this](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/project_resources) | resource |
| [digitalocean_record.additional](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/record) | resource |
| [digitalocean_record.this](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/record) | resource |
| [digitalocean_reserved_ip.this](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/reserved_ip) | resource |
| [digitalocean_volume.this](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/volume) | resource |
| [digitalocean_volume_attachment.this](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/volume_attachment) | resource |
| [digitalocean_volume_snapshot.this](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/volume_snapshot) | resource |
| [null_resource.additional_commands](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.cloudinit](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.environment_variables](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.etc_hosts](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.files](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.swap](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.volume_mount](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [cloudflare_dns_record.this](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/data-sources/dns_record) | data source |
| [cloudflare_zone.this](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/data-sources/zone) | data source |
| [cloudflare_zones.this](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/data-sources/zones) | data source |
| [digitalocean_domain.this](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/data-sources/domain) | data source |
| [digitalocean_droplet_snapshot.this](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/data-sources/droplet_snapshot) | data source |
| [digitalocean_project.this](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/data-sources/project) | data source |
| [digitalocean_ssh_key.remote_provisioner](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/data-sources/ssh_key) | data source |
| [digitalocean_ssh_key.user](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/data-sources/ssh_key) | data source |
| [digitalocean_vpc.this](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_cname_records"></a> [app\_cname\_records](#input\_app\_cname\_records) | List with CNAME records for droplet | `list(string)` | `[]` | no |
| <a name="input_app_configurations"></a> [app\_configurations](#input\_app\_configurations) | The path to the directories with configurations that will be copied to the created server | `string` | `"configurations/"` | no |
| <a name="input_app_data"></a> [app\_data](#input\_app\_data) | The path to the directory for storing persistent information and configurations | `string` | `"/opt"` | no |
| <a name="input_cloudflare_dns_settings"></a> [cloudflare\_dns\_settings](#input\_cloudflare\_dns\_settings) | Settings for all Cloudflare DNS records. Required if `dns_provider` is set to 'cloudflare'. | <pre>object({<br>    proxied = bool<br>    ttl     = number<br>  })</pre> | <pre>{<br>  "proxied": true,<br>  "ttl": 3600<br>}</pre> | no |
| <a name="input_dns_provider"></a> [dns\_provider](#input\_dns\_provider) | DNS provider to manage records for the droplet. Supported: 'digitalocean', 'cloudflare'. Default: 'digitalocean' | `string` | `"digitalocean"` | no |
| <a name="input_droplet_backups"></a> [droplet\_backups](#input\_droplet\_backups) | Enable backups for droplet | `bool` | `false` | no |
| <a name="input_droplet_dns_record"></a> [droplet\_dns\_record](#input\_droplet\_dns\_record) | Create an external dns record for this droplet in `droplet_dns_zone` | `bool` | `true` | no |
| <a name="input_droplet_dns_zone"></a> [droplet\_dns\_zone](#input\_droplet\_dns\_zone) | Name of the domain zone to create an external dns record for this droplet | `string` | n/a | yes |
| <a name="input_droplet_do_agent"></a> [droplet\_do\_agent](#input\_droplet\_do\_agent) | Enable DigitalOcean agent for droplet (for monitoring and backups) | `bool` | `true` | no |
| <a name="input_droplet_do_monitoring"></a> [droplet\_do\_monitoring](#input\_droplet\_do\_monitoring) | Enable monitoring for droplet (for graphs and alerts) | `bool` | `true` | no |
| <a name="input_droplet_image"></a> [droplet\_image](#input\_droplet\_image) | The image of the droplet (must be available in the region). Default: ubuntu-24-04.rev1 | `string` | `"ubuntu-24-04.rev1"` | no |
| <a name="input_droplet_name"></a> [droplet\_name](#input\_droplet\_name) | The name of the droplet (must be unique) | `string` | n/a | yes |
| <a name="input_droplet_project"></a> [droplet\_project](#input\_droplet\_project) | The target project for the droplet | `string` | n/a | yes |
| <a name="input_droplet_provisioner_external_ip"></a> [droplet\_provisioner\_external\_ip](#input\_droplet\_provisioner\_external\_ip) | External IP for provisioner connection to droplet | `bool` | `false` | no |
| <a name="input_droplet_provisioner_ssh_key"></a> [droplet\_provisioner\_ssh\_key](#input\_droplet\_provisioner\_ssh\_key) | Private key for provisioner connection to droplet (must be base64 encoded) | `string` | n/a | yes |
| <a name="input_droplet_region"></a> [droplet\_region](#input\_droplet\_region) | The region of the droplet (must be available) | `string` | `"ams3"` | no |
| <a name="input_droplet_reserved_ip"></a> [droplet\_reserved\_ip](#input\_droplet\_reserved\_ip) | Link a reserved address to a droplet | `bool` | `false` | no |
| <a name="input_droplet_size"></a> [droplet\_size](#input\_droplet\_size) | The size of the droplet (must be available in the region) | `string` | `"s-1vcpu-512mb-10gb"` | no |
| <a name="input_droplet_tags"></a> [droplet\_tags](#input\_droplet\_tags) | The tags of the droplet (for firewall rules) | `list(any)` | n/a | yes |
| <a name="input_droplet_user"></a> [droplet\_user](#input\_droplet\_user) | Name for creating a new user on the server (must be unique) | `string` | n/a | yes |
| <a name="input_droplet_volume_size"></a> [droplet\_volume\_size](#input\_droplet\_volume\_size) | Additional volume size (if required) | `number` | `0` | no |
| <a name="input_os_commands"></a> [os\_commands](#input\_os\_commands) | List of commands to execute custom remote-exec | `list(string)` | `null` | no |
| <a name="input_os_environment_variables"></a> [os\_environment\_variables](#input\_os\_environment\_variables) | List with environmetn variables for server | `list(any)` | `[]` | no |
| <a name="input_os_hosts"></a> [os\_hosts](#input\_os\_hosts) | List with /etc/hosts | `list(string)` | `[]` | no |
| <a name="input_os_packages"></a> [os\_packages](#input\_os\_packages) | List of packages to install | `list(string)` | `[]` | no |
| <a name="input_os_swap_size"></a> [os\_swap\_size](#input\_os\_swap\_size) | Size of swap in GB | `number` | `0` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_droplet_dns"></a> [droplet\_dns](#output\_droplet\_dns) | Droplet DNS record info for DigitalOcean provider, if applicable. |
| <a name="output_droplet_info"></a> [droplet\_info](#output\_droplet\_info) | Droplet base info |
| <a name="output_droplet_networks"></a> [droplet\_networks](#output\_droplet\_networks) | Droplet networks addresses |
| <a name="output_droplet_user"></a> [droplet\_user](#output\_droplet\_user) | Created user for ssh droplet |
| <a name="output_droplet_volume"></a> [droplet\_volume](#output\_droplet\_volume) | Droplet additional volume info |
