# Change Log
All notable changes to this project will be documented in this file.
The format is based on [Keep a Changelog](http://keepachangelog.com/) and this project adheres to [Semantic Versioning](http://semver.org/).


## v2.0.0 - 2025-06-18
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
