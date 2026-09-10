variable "droplet_user" {
  description = "Name for creating a new user on the server (must be unique)"
  type        = string
}

variable "droplet_name" {
  description = "The name of the droplet (must be unique)"
  type        = string
  # Null is temporary default to avoid breaking changes for existing setups, will be changed in future releases after removing `droplet_name_override`
  default = null
}

variable "droplet_name_override" {
  description = "Override for droplet name (if you want to use a specific name format, e.g. without region suffix). Temporary parameter for compatibility with existing setups, will be removed in future releases. Default: null"
  type        = string
  default     = null
}

variable "droplet_image" {
  description = "The image slug or snapshot name or numeric ID for the droplet (must be available in the region). Examples: 'ubuntu-22-04-x64', 'my-custom-snapshot', '12345678'. Default: 'ubuntu-22-04-x64'"
  type        = any
  default     = "ubuntu-22-04-x64"
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

variable "droplet_provisioner_ssh_key_name" {
  description = "Name of the SSH key in DigitalOcean for provisioner connection to droplet to execute remote-exec. Default: 'terraform'"
  type        = string
  default     = "terraform"
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
  description = "List with environment variables for server"
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
  type = object({
    proxied = bool
    ttl     = number
  })
  default = {
    proxied = true
    ttl     = 3600
  }
}

variable "os_secrets_agent" {
  description = "Install https://github.com/obervinov/secrets-agent on the droplet. It fetches a JSON object of variables from an authenticated HTTPS endpoint and applies them to docker compose, to systemd units through a drop-in, and to per-variable files for images that read *_FILE. Leave null to not install it."

  type = object({
    # Release tag to install, e.g. "v1.1.0". Pinned rather than latest: the binary is
    # verified against the SHA256SUMS of this exact release.
    version = string

    url          = string
    auth_headers = map(string)

    # At least one consumer has to be configured. A host that only feeds systemd units
    # needs no compose file, and the reverse.
    compose_file = optional(string)
    systemd_units = optional(list(object({
      unit     = string
      prefix   = string
      env_file = optional(string)
      group    = optional(string)
    })), [])

    interval     = optional(string, "*:0/15")
    files_mode   = optional(string, "0644")
    routed_files = optional(map(string), {})

    # Values this module owns rather than the secret store: derived from resources
    # terraform manages, plus non-secret ones a systemd unit cannot read from
    # /etc/environment.
    terraform_env = optional(map(string), {})
  })

  default   = null
  sensitive = true

  validation {
    condition     = var.os_secrets_agent == null ? true : can(regex("^v[0-9]+\\.[0-9]+\\.[0-9]+$", var.os_secrets_agent.version))
    error_message = "os_secrets_agent.version must be a release tag such as v1.1.0."
  }

  validation {
    condition     = var.os_secrets_agent == null ? true : startswith(var.os_secrets_agent.url, "https://")
    error_message = "os_secrets_agent.url must be https: the agent refuses to send its credential in cleartext."
  }

  validation {
    condition     = var.os_secrets_agent == null ? true : (try(var.os_secrets_agent.compose_file, null) != null || length(var.os_secrets_agent.systemd_units) > 0)
    error_message = "os_secrets_agent configures no consumer: set compose_file, systemd_units or both."
  }
}
