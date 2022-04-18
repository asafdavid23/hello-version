terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.17.0"
    }
  }
}

provider "google" {
  project     = "qwilt-candidate"
  region      = "europe-west3"
}