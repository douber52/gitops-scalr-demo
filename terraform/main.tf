terraform {
  required_version = ">= 1.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

# Random suffix to ensure unique bucket name
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# Main demo GCS bucket
resource "google_storage_bucket" "demo" {
  name     = "goodrx-gitops-demo-${random_id.bucket_suffix.hex}"
  location = var.gcp_region

  # Prevent accidental deletion
  force_destroy = false

  # Enable uniform bucket-level access
  uniform_bucket_level_access = true

  # Uses Google-managed encryption by default (no encryption block needed)

  # Lifecycle rule to demonstrate configuration management
  lifecycle_rule {
    condition {
      age        = 90
      with_state = "ARCHIVED"
    }
    action {
      type = "Delete"
    }
  }

  lifecycle_rule {
    condition {
      num_newer_versions = 3
    }
    action {
      type = "Delete"
    }
  }

  labels = {
    name        = "goodrx-gitops-demo"
    environment = var.environment
    managed_by  = "scalr"
    project     = "gitops-demo"
  }

  # Enable versioning for compliance and data protection
  versioning {
    enabled = true
  }
}

# Public access prevention
resource "google_storage_bucket_iam_binding" "public_access_prevention" {
  bucket = google_storage_bucket.demo.name
  role   = "roles/storage.objectViewer"

  members = [] # No public access
}

# Example: Upload a sample object to demonstrate bucket functionality
resource "google_storage_bucket_object" "readme" {
  name    = "README.txt"
  bucket  = google_storage_bucket.demo.name
  content = "This is a demo bucket managed by Spacelift for GoodRx GitOps demonstration."
}
