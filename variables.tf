variable "droplet_username" {
  description = "Name for creating a new user"
  type        = string
}

variable "packages_list" {
  description = "List of packages to install"
  type        = list(string)
  default     = []
}

variable "persistent_data_path" {
  description = "The path to the directory for storing persistent information and configurations"
  type        = string
  default     = "/opt"
}

variable "remote_commands" {
  description = "List of commands to execute custom remote-exec"
  type        = list(string)
  default     = null
}

variable "remote_files" {
  description = "The path to the directories with configurations that will be copied to the created server"
  type        = string
  default     = "configs/"
}

variable "droplet_name" {
  description = "The name of the droplet"
  type        = string
  default     = "server-0001"
}

variable "droplet_image" {
  description = "The image of the droplet"
  type        = string
  default     = "ubuntu-23-04-x64"
}

variable "droplet_region" {
  description = "The region of the droplet"
  type        = string
  default     = "ams3"
}

variable "droplet_size" {
  description = "The size of the droplet"
  type        = string
  default     = "s-1vcpu-1gb"
}

variable "droplet_tags" {
  description = "The tags of the droplet"
  type        = list(any)
}

variable "droplet_project_name" {
  description = "The target project for the droplet"
  type        = string
}

variable "droplet_reserved_ip" {
  description = "Link a reserved address to a droplet"
  type        = bool
  default     = false
}

variable "droplet_dns_record" {
  description = "Create a dns record for this droplet"
  type        = bool
  default     = true
}

variable "domain_zone" {
  description = "Name of the domain zone to create record"
  type        = string
  default     = ""
}

variable "additional_volume_size" {
  description = "Additional volume size (if required)"
  type        = number
  default     = 0
}

variable "environment_variables" {
  description = "List with environmetn variables for server"
  type        = list(any)
  default     = null
}

variable "droplet_backups" {
  description = "Enable backups for droplet"
  type        = bool
  default     = false
}

variable "droplet_monitoring" {
  description = "Enable monitoring for droplet"
  type        = bool
  default     = true
}

variable "ssh_private_key" {
  description = "Private key for ssh connection in Terraform Cloud (base64)"
  type        = string
}

variable "droplet_agent" {
  description = "Enable agent for droplet"
  type        = bool
  default     = true
}

variable "consul_agent" {
  description = "Enable consul agent and registration service in Consul"
  type        = bool
  default     = true
}

variable "consul_service_port" {
  description = "Port for registration service in consul"
  type        = number
  default     = 80
}

variable "consul_service_check" {
  description = "Check for registration service in consul"
  type = object({
    check_id                          = string
    name                              = string
    http                              = string
    status                            = string
    tls_skip_verify                   = bool
    method                            = string
    interval                          = string
    timeout                           = string
    deregister_critical_service_after = string
  })
  default = null
}

variable "nameserver_ips" {
  description = "Private IPs for cloudinit nameserver"
  type        = list(string)
  default     = ["8.8.8.8", "8.8.4.4"]
}

variable "vpc_name" {
  description = "VPC name"
  type        = string
  default     = "default"
}

variable "etc_hosts" {
  description = "List with etc hosts"
  type        = list(string)
  default     = null
}
