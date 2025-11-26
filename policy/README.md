# Spacelift OPA Policies

This directory contains Open Policy Agent (OPA) policies for use with Spacelift. These policies enforce organizational standards and best practices on infrastructure changes.

## Policies

### require-labels.rego
**Type**: Plan Policy

Ensures all GCS buckets have required labels for governance and tracking.

**Required Labels**:
- `environment`: Environment name (dev, staging, prod, demo)
- `managed_by`: Tool managing the resource (e.g., "spacelift")

**Recommended Labels** (warnings):
- `owner`: Team or person responsible
- `project`: Project name for cost tracking

### security-best-practices.rego
**Type**: Plan Policy

Enforces security best practices on GCS buckets.

**Rules**:
- ❌ DENY: Public access to buckets (allUsers, allAuthenticatedUsers)
- ❌ DENY: Buckets without uniform bucket-level access
- ⚠️ WARN: Buckets without customer-managed encryption keys
- ⚠️ WARN: Buckets without versioning enabled

### cost-optimization.rego
**Type**: Plan Policy

Helps prevent costly misconfigurations.

**Rules**:
- ⚠️ WARN: Buckets without lifecycle rules
- ⚠️ WARN: Buckets without explicit storage class
- ❌ DENY: Multi-region buckets without justification

## Usage in Spacelift

### Option 1: Create Policies in Spacelift UI

1. Go to **Policies** in Spacelift
2. Click **Create Policy**
3. Copy the contents of the `.rego` file
4. Set:
   - **Name**: Policy name (e.g., "require-labels")
   - **Type**: Plan
   - **Body**: Paste the policy code
5. Click **Create**
6. Attach to your stack via **Stack** → **Policies** → **Attach Policy**

### Option 2: Use Spacelift Terraform Provider (Advanced)

You can manage policies as code using the Spacelift Terraform provider:

```hcl
resource "spacelift_policy" "require_labels" {
  name = "require-labels"
  type = "PLAN"
  body = file("${path.module}/policy/require-labels.rego")
}

resource "spacelift_policy_attachment" "require_labels" {
  policy_id = spacelift_policy.require_labels.id
  stack_id  = spacelift_stack.demo.id
}
```

## Testing Policies Locally

You can test OPA policies locally before uploading to Spacelift:

1. **Install OPA**:
   ```bash
   brew install opa
   ```

2. **Test a policy**:
   ```bash
   opa test policy/
   ```

3. **Evaluate against a plan**:
   ```bash
   terraform plan -out=tfplan
   terraform show -json tfplan > plan.json
   opa eval -i plan.json -d policy/require-labels.rego "data.spacelift.deny"
   ```

## Policy Development Best Practices

1. **Start with warnings**: Use `warn` instead of `deny` when rolling out new policies
2. **Test thoroughly**: Test policies against real Terraform plans before enforcing
3. **Document exceptions**: If policies need exceptions, document them clearly
4. **Version control**: Keep policies in version control alongside infrastructure code
5. **Gradual rollout**: Apply policies to dev environments first, then promote to production

## Customizing Policies

To customize these policies for your organization:

1. **Modify required labels** in `require-labels.rego`
2. **Adjust security rules** in `security-best-practices.rego`
3. **Update cost thresholds** in `cost-optimization.rego`
4. **Add new policies** for organization-specific requirements

## Common Policy Patterns

### Require specific resource configuration
```rego
deny["Resource must have X configured"] {
  resource := input.terraform.resource_changes[_]
  resource.type == "google_storage_bucket"
  not resource.change.after.some_field
}
```

### Prevent destructive actions
```rego
deny["Cannot delete production resources"] {
  resource := input.terraform.resource_changes[_]
  resource.change.actions[_] == "delete"
  resource.change.before.labels.environment == "prod"
}
```

### Enforce naming conventions
```rego
deny["Resource names must follow naming convention"] {
  resource := input.terraform.resource_changes[_]
  resource.type == "google_storage_bucket"
  not regex.match("^[a-z][a-z0-9-]*[a-z0-9]$", resource.change.after.name)
}
```

## Additional Resources

- [Spacelift Policies Documentation](https://docs.spacelift.io/concepts/policy)
- [Open Policy Agent Documentation](https://www.openpolicyagent.org/docs/latest/)
- [OPA Rego Language Guide](https://www.openpolicyagent.org/docs/latest/policy-language/)
- [Terraform Plan JSON Format](https://www.terraform.io/internals/json-format)
