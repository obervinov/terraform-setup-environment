# Installs the secrets-agent released by https://github.com/obervinov/secrets-agent.
#
# The binary is downloaded on the host from the pinned release and checked against the
# SHA256SUMS published beside it, so a truncated or tampered download fails the apply
# rather than being installed. Nothing is vendored here: this module carries the
# install, the upstream project carries the code.
#
# The unit and timer are templated rather than fetched because they need this module's
# paths and the caller's interval. The upstream repository keeps its own copies under
# packaging/ for installing by hand.

locals {
  secrets_agent_enabled = var.os_secrets_agent != null ? 1 : 0
  secrets_agent_binary  = "/usr/local/bin/secrets-agent"
  secrets_agent_config  = "/etc/secrets-agent.conf"
  secrets_agent_state   = "/opt/secrets"

  secrets_agent_asset = var.os_secrets_agent == null ? "" : join("/", [
    "https://github.com/obervinov/secrets-agent/releases/download",
    var.os_secrets_agent.version,
  ])

  secrets_agent_unit = var.os_secrets_agent == null ? "" : templatefile("${path.module}/files/secrets-agent/secrets-agent.service.tftpl", {
    binary_path = local.secrets_agent_binary
    config_path = local.secrets_agent_config
    state_dir   = local.secrets_agent_state
  })

  secrets_agent_timer = var.os_secrets_agent == null ? "" : templatefile("${path.module}/files/secrets-agent/secrets-agent.timer.tftpl", {
    interval = var.os_secrets_agent.interval
  })

  secrets_agent_conf = var.os_secrets_agent == null ? "" : templatefile("${path.module}/files/secrets-agent/secrets-agent.conf.tftpl", {
    url          = var.os_secrets_agent.url
    auth_headers = jsonencode(var.os_secrets_agent.auth_headers)
    compose_file = coalesce(var.os_secrets_agent.compose_file, "")
    files_mode   = var.os_secrets_agent.files_mode
    state_dir    = local.secrets_agent_state
    # Optional fields are dropped rather than emitted as null, so the agent falls back
    # to its own defaults instead of reading a key that carries nothing.
    systemd_units = length(var.os_secrets_agent.systemd_units) > 0 ? jsonencode([
      for unit in var.os_secrets_agent.systemd_units : merge(
        { unit = unit.unit, prefix = unit.prefix },
        unit.env_file == null ? {} : { env_file = unit.env_file },
        unit.group == null ? {} : { group = unit.group },
      )
    ]) : ""
  })

  # name=VARIABLE per line, telling the agent which variables also get a file of their
  # own for images that read *_FILE rather than an environment variable.
  secrets_agent_routing = var.os_secrets_agent == null ? "" : join("", [
    for name, variable in var.os_secrets_agent.routed_files : "${name}=${variable}\n"
  ])

  # Values this module owns rather than the secret store: derived from resources
  # terraform manages, plus non-secret ones the agent still has to hand to compose,
  # because a systemd unit does not read /etc/environment.
  #
  # The addresses are merged in here because a caller cannot pass them without creating
  # a cycle through this module's own outputs.
  secrets_agent_tf_env = var.os_secrets_agent == null ? "" : join("", [
    for key, value in merge({
      DROPLET_INTERNAL_IP = digitalocean_droplet.this.ipv4_address_private
      DROPLET_EXTERNAL_IP = digitalocean_droplet.this.ipv4_address
    }, var.os_secrets_agent.terraform_env) : "${key}=${value}\n"
  ])
}

resource "null_resource" "secrets_agent" {
  # After `files`, because the agent's first run brings up compose and the compose file
  # is delivered by that resource.
  depends_on = [
    null_resource.cloudinit,
    null_resource.files,
    null_resource.etc_hosts,
  ]

  count = local.secrets_agent_enabled

  triggers = {
    droplet = digitalocean_droplet.this.id
    version = var.os_secrets_agent.version
    config = nonsensitive(sha256(join("\n---\n", [
      local.secrets_agent_unit,
      local.secrets_agent_timer,
      local.secrets_agent_conf,
      local.secrets_agent_routing,
      local.secrets_agent_tf_env,
    ])))
  }

  connection {
    host        = local.remote_provisioner_host
    user        = local.remote_provisioner_user
    type        = "ssh"
    agent       = false
    timeout     = "3m"
    private_key = base64decode(var.droplet_provisioner_ssh_key)
  }

  provisioner "remote-exec" {
    inline = ["install -d -m 0700 \"$HOME/.secrets-agent\""]
  }

  provisioner "file" {
    content     = local.secrets_agent_unit
    destination = "~/.secrets-agent/secrets-agent.service"
  }

  provisioner "file" {
    content     = local.secrets_agent_timer
    destination = "~/.secrets-agent/secrets-agent.timer"
  }

  provisioner "file" {
    content     = local.secrets_agent_conf
    destination = "~/.secrets-agent/secrets-agent.conf"
  }

  provisioner "file" {
    content     = local.secrets_agent_routing
    destination = "~/.secrets-agent/secrets-agent.files"
  }

  provisioner "file" {
    content     = local.secrets_agent_tf_env
    destination = "~/.secrets-agent/terraform.env"
  }

  provisioner "remote-exec" {
    inline = [
      # Download and verify before anything is installed: a bad download must fail the
      # apply, not leave a broken binary behind.
      "set -eu",
      "cd \"$HOME/.secrets-agent\"",
      "arch=$(uname -m); case \"$arch\" in x86_64) arch=amd64 ;; aarch64) arch=arm64 ;; *) echo \"unsupported architecture $arch\" >&2; exit 1 ;; esac",
      "asset=secrets-agent_${var.os_secrets_agent.version}_linux_$arch",
      "curl -fsSL --retry 3 -o \"$asset\" \"${local.secrets_agent_asset}/$asset\"",
      "curl -fsSL --retry 3 -o SHA256SUMS \"${local.secrets_agent_asset}/SHA256SUMS\"",
      "grep \" $asset$\" SHA256SUMS | sha256sum -c -",

      # root:root 0700 on the install path on purpose: the unit runs this as root, so a
      # directory writable by anyone else would be a root escalation at the next tick.
      "sudo install -m 0755 -o root -g root \"$asset\" ${local.secrets_agent_binary}",
      "sudo install -d -m 0700 -o root -g root ${local.secrets_agent_state}",
      "sudo install -m 0600 -o root -g root secrets-agent.conf ${local.secrets_agent_config}",
      "sudo install -m 0600 -o root -g root terraform.env ${local.secrets_agent_state}/terraform.env",
      "sudo install -m 0644 -o root -g root secrets-agent.files /etc/secrets-agent.files",
      "sudo install -m 0644 -o root -g root secrets-agent.service /etc/systemd/system/secrets-agent.service",
      "sudo install -m 0644 -o root -g root secrets-agent.timer /etc/systemd/system/secrets-agent.timer",
      "cd \"$HOME\" && rm -rf \"$HOME/.secrets-agent\"",
      "sudo systemctl daemon-reload",
      "sudo systemctl enable --now secrets-agent.timer",

      # Run once synchronously, so a wrong credential or endpoint fails the apply
      # instead of surfacing on a timer tick nobody is watching.
      "sudo systemctl start secrets-agent.service",
    ]
  }
}
