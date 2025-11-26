package terraform

# Policy: Cost Optimization for GCS
# Type: Plan Policy
# Description: Helps prevent costly misconfigurations

# Warn if bucket doesn't have lifecycle rules
warn[msg] {
  resource := input.tfplan.resource_changes[_]
  resource.type == "google_storage_bucket"
  resource.change.actions[_] == "create"
  not has_lifecycle_rules(resource)
  msg := sprintf("GCS bucket '%s' should have lifecycle rules to manage costs", [resource.address])
}

# Warn about storage class
warn[msg] {
  resource := input.tfplan.resource_changes[_]
  resource.type == "google_storage_bucket"
  resource.change.actions[_] == "create"
  not resource.change.after.storage_class
  msg := sprintf("GCS bucket '%s' should consider using NEARLINE or COLDLINE storage for infrequently accessed data", [resource.address])
}

# Deny buckets in expensive regions without justification
deny[msg] {
  resource := input.tfplan.resource_changes[_]
  resource.type == "google_storage_bucket"
  resource.change.actions[_] == "create"
  location := resource.change.after.location
  is_multi_region(location)
  not has_multi_region_justification(resource)
  msg := sprintf("GCS bucket '%s' uses multi-region location '%s' which is expensive - use regional buckets unless required", [resource.address, location])
}

# Helper functions
has_lifecycle_rules(resource) {
  count(resource.change.after.lifecycle_rule) > 0
}

is_multi_region(location) {
  location == "US"
}

is_multi_region(location) {
  location == "EU"
}

is_multi_region(location) {
  location == "ASIA"
}

has_multi_region_justification(resource) {
  label := resource.change.after.labels[_]
  label == "multi-region-required"
}
