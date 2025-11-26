package terraform

# Policy: Require Labels on GCS Buckets
# Type: Plan Policy
# Description: Ensures all GCS buckets have required labels for governance

# Deny if GCS bucket doesn't have 'environment' label
deny[msg] {
  resource := input.tfplan.resource_changes[_]
  resource.type == "google_storage_bucket"
  resource.change.actions[_] == "create"
  not resource.change.after.labels.environment
  msg := sprintf("GCS bucket '%s' must have 'environment' label", [resource.address])
}

# Deny if GCS bucket doesn't have 'managed_by' label
deny[msg] {
  resource := input.tfplan.resource_changes[_]
  resource.type == "google_storage_bucket"
  resource.change.actions[_] == "create"
  not resource.change.after.labels.managed_by
  msg := sprintf("GCS bucket '%s' must have 'managed_by' label", [resource.address])
}

# Warn if bucket doesn't have 'owner' label
warn[msg] {
  resource := input.tfplan.resource_changes[_]
  resource.type == "google_storage_bucket"
  resource.change.actions[_] == "create"
  not resource.change.after.labels.owner
  msg := sprintf("GCS bucket '%s' should have 'owner' label for better tracking", [resource.address])
}

# Warn if bucket doesn't have 'project' label
warn[msg] {
  resource := input.tfplan.resource_changes[_]
  resource.type == "google_storage_bucket"
  resource.change.actions[_] == "create"
  not resource.change.after.labels.project
  msg := sprintf("GCS bucket '%s' should have 'project' label for cost tracking", [resource.address])
}
