package terraform

# Policy: Security Best Practices for GCS
# Type: Plan Policy
# Description: Enforces security best practices on GCS buckets

# Deny public buckets
deny[msg] {
  resource := input.tfplan.resource_changes[_]
  resource.type == "google_storage_bucket_iam_binding"
  member := resource.change.after.members[_]
  member == "allUsers"
  msg := sprintf("GCS bucket IAM binding '%s' must not allow public access (allUsers)", [resource.address])
}

deny[msg] {
  resource := input.tfplan.resource_changes[_]
  resource.type == "google_storage_bucket_iam_binding"
  member := resource.change.after.members[_]
  member == "allAuthenticatedUsers"
  msg := sprintf("GCS bucket IAM binding '%s' must not allow public access (allAuthenticatedUsers)", [resource.address])
}

# Require uniform bucket-level access
deny[msg] {
  resource := input.tfplan.resource_changes[_]
  resource.type == "google_storage_bucket"
  resource.change.actions[_] == "create"
  not resource.change.after.uniform_bucket_level_access
  msg := sprintf("GCS bucket '%s' must have uniform bucket-level access enabled", [resource.address])
}

# Warn about encryption
warn[msg] {
  resource := input.tfplan.resource_changes[_]
  resource.type == "google_storage_bucket"
  resource.change.actions[_] == "create"
  not has_cmek_encryption(resource)
  msg := sprintf("GCS bucket '%s' should consider using customer-managed encryption keys (CMEK) for sensitive data", [resource.address])
}

# Helper function to check for CMEK encryption
has_cmek_encryption(resource) {
  resource.change.after.encryption[_].default_kms_key_name
}

# Warn about versioning
warn[msg] {
  resource := input.tfplan.resource_changes[_]
  resource.type == "google_storage_bucket"
  resource.change.actions[_] == "create"
  not has_versioning(resource)
  msg := sprintf("GCS bucket '%s' should consider enabling versioning for data protection", [resource.address])
}

# Helper function to check if versioning is enabled
has_versioning(resource) {
  resource.change.after.versioning[_].enabled == true
}
