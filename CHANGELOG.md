# Change Log
All notable changes to this project will be documented in this file.
The format is based on [Keep a Changelog](http://keepachangelog.com/) and this project adheres to [Semantic Versioning](http://semver.org/).


## v2.1.0 - 2025-09-23
### What's Changed
**Full Changelog**: https://github.com/obervinov/terraform-setup-environment/compare/v2.0.1...v2.1.0 by @obervinov
#### 🚀 Features
* added an additional parameter `droplet_image_id` to support direct image ID usage instead of resolving the image slug (useful for cases with imported legacy droplets that reference images no longer available in the DO catalog. Parameter used as mocked in the `data.digitalocean_droplet_snapshot` data source to avoid resolution errors)
* added an additional parameter `droplet_name_override` to support custom droplet name formats (useful for cases with imported legacy droplets that do not follow the default naming convention with region suffix). This is a temporary parameter for compatibility with existing setups and will be removed in future releases.
* added an additional parameter `droplet_provisioner_ssh_key_name` to specify the name of the SSH key in DigitalOcean for provisioner connection to droplet to execute remote-exec (default: "terraform")
#### 💥 Breaking Changes
* default value of the `droplet_image` variable changed from `ubuntu-24-04.rev1` to `ubuntu-22-04-x64` from public catalog (to avoid confusion with private snapshots that may not be available for all users)


## v2.0.1 - 2025-06-24
### What's Changed
**Full Changelog**: https://github.com/obervinov/terraform-setup-environment/compare/v2.0.0...v2.0.1 by @obervinov
#### 🐛 Bug Fixes
* fix `dns_record` output for the Cloudflare DNS provider


## v2.0.0 - 2025-06-24
### What's Changed
**Full Changelog**: https://github.com/obervinov/terraform-setup-environment/compare/v1.1.0...v2.0.0 by @obervinov
#### 💥 Breaking Changes
* update supported cloud-init version to 2.0.0 and remove support for 1.x versions
* update default image to ubuntu-24-04.rev1
* bump terraform version to 1.11
* remove default packages from cloud-init configuration
#### 🚀 Features
* add support for the Cloudflare DNS provider


## v1.1.0 - 2025-01-13
### What's Changed
**Full Changelog**: https://github.com/obervinov/terraform-setup-environment/compare/v1.0.1...v1.1.0 by @obervinov
#### 🚀 Features
* add support for the droplet_provisioner_external_ip variable for the remote provider


## v1.0.1 - 2025-01-12
### What's Changed
**Full Changelog**: https://github.com/obervinov/terraform-setup-environment/compare/v1.0.0...v1.0.1 by @obervinov
#### 🐛 Bug Fixes
* fix typos


## v1.0.0 - 2025-01-12
### What's Changed
**Full Changelog**: https://github.com/obervinov/terraform-setup-environment/commits/v1.0.0 by @obervinov
#### 💥 Breaking Changes
* first release of the module
