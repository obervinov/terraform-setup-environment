# Prepare the environment for the application
# Set the environment variables, copy the files and execute the commands

resource "null_resource" "cloudinit" {
  triggers = {
    run_always = timestamp()
  }

  connection {
    host        = digitalocean_droplet.default.ipv4_address_private
    user        = "terraform"
    type        = "ssh"
    agent       = false
    timeout     = "3m"
    private_key = base64decode(var.droplet_ssh_key)

  }
  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait"
    ]
  }

  depends_on = [
    digitalocean_droplet.default
  ]
}

resource "null_resource" "etc_hosts" {
  count = var.os_hosts != null && length(var.os_hosts) > 0 ? 1 : 0

  triggers = {
    hash = sha1(join(",", var.os_hosts))
  }

  connection {
    host        = digitalocean_droplet.default.ipv4_address_private
    user        = "terraform"
    type        = "ssh"
    agent       = false
    timeout     = "3m"
    private_key = base64decode(var.droplet_ssh_key)
  }

  provisioner "remote-exec" {
    inline = [
      "echo '${join("\n", var.os_hosts)}' | sudo tee -a /etc/hosts > /dev/null",
      "echo '${join("\n", var.os_hosts)}' | sudo tee -a /etc/cloud/templates/hosts.debian.tmpl > /dev/null",
    ]
  }

  depends_on = [
    null_resource.cloudinit
  ]
}

resource "null_resource" "swap" {
  count = can(var.os_swap_size) && var.os_swap_size > 0 ? 1 : 0

  triggers = {
    os_swap_size = var.os_swap_size
  }

  connection {
    host        = digitalocean_droplet.default.ipv4_address_private
    user        = "terraform"
    type        = "ssh"
    agent       = false
    timeout     = "3m"
    private_key = base64decode(var.droplet_ssh_key)
  }

  provisioner "remote-exec" {
    inline = [
      "sudo fallocate -l ${var.os_swap_size}G /swapfile",
      "sudo chmod 600 /swapfile",
      "sudo mkswap /swapfile",
      "sudo swapon /swapfile",
      "new_line='/swapfile none swap sw 0 0' && grep -q $new_line /etc/fstab || echo $new_line | sudo tee -a /etc/fstab",
      "new_line='vm.swappiness=10' && grep -q $new_line /etc/sysctl.conf || echo $new_line | sudo tee -a /etc/sysctl.conf",
      "sudo sysctl -p > /dev/null"
    ]
  }

  depends_on = [
    null_resource.cloudinit
  ]
}

resource "null_resource" "environment_variables" {
  count = var.os_environment_variables != null && length(var.os_environment_variables) > 0 ? 1 : 0

  triggers = {
    always_run = timestamp()
  }

  connection {
    host        = digitalocean_droplet.default.ipv4_address_private
    user        = "terraform"
    type        = "ssh"
    agent       = false
    timeout     = "3m"
    private_key = base64decode(var.droplet_ssh_key)
  }
  provisioner "remote-exec" {
    inline = [
      "echo PATH='/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin' | sudo tee /etc/environment > /dev/null",
      "echo '${join("\n", local.environment_variables)}' | sudo tee -a /etc/environment > /dev/null",
      "echo '${join("\n", var.os_environment_variables)}' | sudo tee -a /etc/environment > /dev/null"
    ]
  }

  depends_on = [
    null_resource.cloudinit
  ]
}

resource "null_resource" "files" {
  count = can(var.app_configurations) && fileset(var.app_configurations, "*") != [] ? 1 : 0

  triggers = {
    always_run = timestamp()
  }

  connection {
    host        = digitalocean_droplet.default.ipv4_address_private
    user        = "terraform"
    type        = "ssh"
    agent       = false
    timeout     = "3m"
    private_key = base64decode(var.droplet_ssh_key)
  }
  provisioner "file" {
    source      = "${var.app_configurations}/"
    destination = "${var.app_data}/${var.app_configurations}"
  }

  depends_on = [
    null_resource.cloudinit
  ]
}

resource "null_resource" "additional_commands" {
  count = length(coalesce(var.os_commands, [])) > 0 ? 1 : 0
  triggers = {
    always_run = timestamp()
  }

  connection {
    host        = digitalocean_droplet.default.ipv4_address_private
    user        = "terraform"
    type        = "ssh"
    agent       = false
    timeout     = "3m"
    private_key = base64decode(var.droplet_ssh_key)
  }
  provisioner "remote-exec" {
    inline = var.os_commands
  }

  depends_on = [
    null_resource.cloudinit,
    null_resource.files,
    null_resource.etc_hosts,
    null_resource.environment_variables
  ]
}

resource "null_resource" "loki" {
  count = can(var.os_loki_driver) && var.os_loki_driver == 1 ? 1 : 0

  triggers = {
    always_run = timestamp()
  }

  connection {
    host        = digitalocean_droplet.default.ipv4_address_private
    user        = "terraform"
    type        = "ssh"
    agent       = false
    timeout     = "3m"
    private_key = base64decode(var.droplet_ssh_key)
  }

  provisioner "remote-exec" {
    inline = [
      "docker plugin install grafana/loki-docker-driver:${var.os_loki_driver_version} --alias loki --grant-all-permissions",
      "docker plugin enable loki",
      "systemctl restart docker"
    ]
  }

  provisioner "file" {
    content     = <<EOF
{
    "debug" : true,
    "log-driver": "loki",
    "log-opts": {
        "loki-url": "${var.os_loki_driver_url}",
        "loki-batch-size": "400"
    }
}
EOF
    destination = "/etc/docker/daemon.json"
  }

  depends_on = [
    null_resource.cloudinit
  ]
}