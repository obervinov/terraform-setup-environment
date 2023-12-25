terraform {
  required_version = ">= 1.5.2"

  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = ">= 2.28.1"
    }
    consul = {
      source  = "hashicorp/consul"
      version = "2.20.0"
    }
  }
}