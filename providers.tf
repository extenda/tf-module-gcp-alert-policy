terraform {
  # The configuration for this backend will be filled in by Terragrunt
  required_version = ">= 0.13.0"
  required_providers {
    google = {
      source = "hashicorp/google"
      version = ">= 5.13.0"
    }
  }
}
