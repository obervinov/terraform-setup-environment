locals {
  user_data = <<EOF
#cloud-config
users:
  - name: ${var.droplet_username}
    groups: ['sudo']
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    ssh-authorized-keys:
      - "${tr("\n", "", data.digitalocean_ssh_key.key.public_key)}"
  - name: terraform
    groups: ['sudo']
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    ssh-authorized-keys:
      - "${tr("\n", "", data.digitalocean_ssh_key.key.public_key)}"

ssh_pwauth: false
disable_root: true
package_update: true
package_upgrade: true
manage_etc_hosts: true
manage_resolv_conf: true

resolv_conf:
  nameservers:
${join("\n", formatlist("    - '%s'", var.nameserver_ips))}
  searchdomains:
    - service.consul
  domain: 'consul'
  options:
    rotate: true
    timeout: 1

packages:
  - 'apt-transport-https'
  - 'ca-certificates'
  - 'curl'
  - 'software-properties-common'
  - 'net-tools'
  - 'gpg'
${var.packages_list != null ? join("\n", formatlist("  - '%s'", var.packages_list)) : ""}

runcmd:
  # Install docker for all environment
  - 'curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg'
  - 'echo "deb [arch=\"$(dpkg --print-architecture)\" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \"$$(. /etc/os-release && echo \"$VERSION_CODENAME\")\" stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null'
  - 'DEBIAN_FRONTEND=noninteractive DEBIAN_PRIORITY=critical sudo apt-get -y update && sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin'
  - 'sudo usermod -aG docker ${var.droplet_username}'
  # Directory for configuration files provisioner
  - 'sudo mkdir -p ${var.persistent_data_path}/configs && sudo chown ${var.droplet_username}.terraform ${var.persistent_data_path}/configs && sudo chmod 775 ${var.persistent_data_path}/configs'
EOF
}

data "digitalocean_ssh_key" "key" {
  name = var.droplet_username
}

data "digitalocean_ssh_key" "terraform_key" {
  name = "terraform"
}

data "digitalocean_project" "project" {
  name = var.droplet_project_name
}

data "digitalocean_domain" "domain" {
  name = var.domain_zone
}
