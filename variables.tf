variable "droplet_user" {
  description = "Name for creating a new user on the server (must be unique)"
  type        = string
}

variable "droplet_name" {
  description = "The name of the droplet (must be unique)"
  type        = string
}

variable "droplet_image" {
  description = "The image of the droplet (must be available in the region). Default: ubuntu-24-04.rev1"
  type        = string
  default     = "ubuntu-24-04.rev1"
}

variable "droplet_region" {
  description = "The region of the droplet (must be available)"
  type        = string
  default     = "ams3"
}

variable "droplet_size" {
  description = "The size of the droplet (must be available in the region)"
  type        = string
  default     = "s-1vcpu-512mb-10gb"
}

variable "droplet_tags" {
  description = "The tags of the droplet (for firewall rules)"
  type        = list(any)
}

variable "droplet_project" {
  description = "The target project for the droplet"
  type        = string
}

variable "droplet_reserved_ip" {
  description = "Link a reserved address to a droplet"
  type        = bool
  default     = false
}

variable "droplet_dns_record" {
  description = "Create an external dns record for this droplet in `droplet_dns_zone`"
  type        = bool
  default     = true
}

variable "droplet_dns_zone" {
  description = "Name of the domain zone to create an external dns record for this droplet"
  type        = string
}

variable "droplet_volume_size" {
  description = "Additional volume size (if required)"
  type        = number
  default     = 0
}

variable "droplet_backups" {
  description = "Enable backups for droplet"
  type        = bool
  default     = false
}

variable "droplet_do_monitoring" {
  description = "Enable monitoring for droplet (for graphs and alerts)"
  type        = bool
  default     = true
}

variable "droplet_provisioner_ssh_key" {
  description = "Private key for provisioner connection to droplet (must be base64 encoded)"
  type        = string
}

variable "droplet_provisioner_external_ip" {
  description = "External IP for provisioner connection to droplet"
  type        = bool
  default     = false
}

variable "droplet_do_agent" {
  description = "Enable DigitalOcean agent for droplet (for monitoring and backups)"
  type        = bool
  default     = true
}

variable "os_packages" {
  description = "List of packages to install"
  type        = list(string)
  default     = []
}

variable "os_commands" {
  description = "List of commands to execute custom remote-exec"
  type        = list(string)
  default     = null
}

variable "os_environment_variables" {
  description = "List with environmetn variables for server"
  type        = list(any)
  default     = []
}

variable "os_swap_size" {
  description = "Size of swap in GB"
  type        = number
  default     = 0
}

variable "os_hosts" {
  description = "List with /etc/hosts"
  type        = list(string)
  default     = []
}

variable "app_data" {
  description = "The path to the directory for storing persistent information and configurations"
  type        = string
  default     = "/opt"
}

variable "app_configurations" {
  description = "The path to the directories with configurations that will be copied to the created server"
  type        = string
  default     = "configurations/"
}

variable "app_cname_records" {
  description = "List with CNAME records for droplet"
  type        = list(string)
  default     = []
}

variable "dns_provider" {
  description = "DNS provider to manage records for the droplet. Supported: 'digitalocean', 'cloudflare'. Default: 'digitalocean'"
  type        = string
  default     = "digitalocean"
}

variable "cloudflare_dns_settings" {
  description = "Settings for all Cloudflare DNS records. Required if `dns_provider` is set to 'cloudflare'."
  type        = map(any)
  default = {
    proxied   = true
    ipv4_only = true
    ipv6_only = false
    ttl       = 3600
  }
}
