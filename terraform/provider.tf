terraform {
  required_version = ">=1.10"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.12"
    }

    sops = {
      source  = "carlpett/sops"
      version = "~> 1.0"
    }
  }

  backend "gcs" {
    bucket = "gek-simple-api-terraform-state"
    prefix = "terraform/state"
  }
}

provider "google" {
  project = "gke-simple-api"
  region  = "asia-northeast1-a"
}

provider "sops" {}
