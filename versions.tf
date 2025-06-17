terraform {
  required_version = ">= 1.11"

  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = ">= 2"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.52.0"
    }
  }
}
