version = "v1"

policy "require-labels" {
  enabled           = true
  enforcement_level = "hard-mandatory"
  file              = "require-labels.rego"
}

policy "security-best-practices" {
  enabled           = true
  enforcement_level = "hard-mandatory"
  file              = "security-best-practices.rego"
}

policy "cost-optimization" {
  enabled           = true
  enforcement_level = "soft-mandatory"
  file              = "cost-optimization.rego"
}
