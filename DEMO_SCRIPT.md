# Scalr GitOps Live Demo Script

**Presenter**: Roy Douber
**Duration**: 15-20 minutes
**Audience**: GoodRx Team
**Platform**: Scalr

---

## Pre-Demo Checklist

Before starting the demo, ensure:

- [ ] Scalr workspace is running and healthy
- [ ] PR #1 is open (NOT merged) - shows lifecycle rule addition
- [ ] Browser tabs open:
  - [ ] GitHub repository
  - [ ] Pull Request #1
  - [ ] Scalr dashboard
  - [ ] GCP Console - Cloud Storage
- [ ] Logged into all services (GitHub, Scalr, GCP)
- [ ] Screen sharing ready, notifications muted

---

## Demo Overview

**Key Message**: "GitOps with Scalr makes infrastructure changes safe, visible, and auditable through hierarchical governance and policies-as-code."

**Demo Flow**:
1. **GitOps PR Workflow** (5-7 min) - Infrastructure changes via Pull Requests
2. **Drift Detection** (3-4 min) - Scalr's three remediation options
3. **Policy Enforcement** (5 min) - Policy Groups in VCS and Policy Impact Analysis

---

## Part 1: GitOps PR Workflow (5-7 minutes)

### Talking Points Introduction
*"Traditional infrastructure management is error-prone: manual terraform runs, no review process, unclear audit trail. GitOps with Scalr solves this through automation, hierarchy, and policy enforcement."*

### Step 1: Show the Repository
**Navigate to**: GitHub repository

**What to show**:
- Project structure with `terraform/` directory
- `policy/` directory with OPA policies
- **Key difference**: `scalr-policy.hcl` configuration file

**Say**:
> "All infrastructure is version-controlled. With Scalr, even our policies are in Git via the policy directory. This means policy changes go through the same review process as infrastructure changes. Notice the scalr-policy.hcl file - this configures which policies run and their enforcement levels."

### Step 2: Introduce the Pull Request
**Navigate to**: PR #1 in GitHub

**What to show**:
- PR title and description
- GitHub status check from Scalr
- Green checkmark ✅

**Say**:
> "When developers propose infrastructure changes, they create a pull request. Scalr watches the repository and automatically triggers a terraform plan. Let's see what makes Scalr's approach powerful..."

### Step 3: Show Scalr's Automatic Plan in PR
**Scroll to Scalr's PR comment**

**What to point out**:
- Detailed plan summary in PR comment
- Workspace information
- Resource changes breakdown
- **Policy evaluation results** (pre-plan and post-plan)
- Cost estimation (if enabled)
- Link to full run details

**Say**:
> "Scalr automatically ran terraform plan and evaluated our policies. The comment shows exactly what will change, policy results, and estimated costs. Notice the policy checks - Scalr runs them at both pre-plan and post-plan stages for faster feedback and comprehensive validation."

**Scalr-specific benefits to highlight**:
- ✅ Hierarchical organization (Account → Environment → Workspace)
- ✅ Policies evaluated automatically
- ✅ Clear policy enforcement levels (advisory, soft-mandatory, hard-mandatory)
- ✅ No manual terraform commands needed

### Step 4: Review in Scalr UI
**Navigate to**: Scalr → Workspace → PR run

**What to show**:
- Run phases: Initializing → Planning → Policy Checks → Cost Estimation
- Detailed plan output
- Policy evaluation details
- Resource graph (if available)

**Say**:
> "In Scalr's UI, we get even more detail. You can see the run went through multiple phases including policy checks. Scalr's hierarchical model means this workspace inherits configurations from its environment, making it easy to standardize across teams."

### Step 5: Merge the Pull Request (LIVE ACTION)
**Action**: Click "Merge pull request" → "Confirm merge"

**Say**:
> "When we merge to main, Scalr detects the change and automatically triggers a tracked run. This is GitOps in action - Git drives infrastructure, not manual commands."

### Step 6: Show Automatic Deployment Trigger
**Navigate to**: Scalr → Workspace

**What to show**:
- New run triggered from main branch merge
- Run status: Planning
- Commit information

**Say**:
> "Scalr automatically started a new run from the main branch. This workspace is configured to require manual approval before applying, but we could enable auto-apply for lower environments."

### Step 7: Approve the Deployment (LIVE ACTION)
**Action**: Click "Confirm & Apply" in Scalr

**What to show**:
- Apply phase running
- Real-time logs
- Apply completes successfully

**Say**:
> "I'm approving manually for this demo. In production, you might use Scalr's approval policies to require sign-off from multiple teams, or auto-deploy after successful policy checks. Scalr's flexibility lets you match your organizational workflows."

### Step 8: Verify in GCP (Optional)
**Navigate to**: GCP Console → Cloud Storage → Bucket

**What to show**:
- Bucket exists with new lifecycle rule
- Labels show `managed_by = scalr`

**Say**:
> "Infrastructure now matches Git. Complete audit trail - we know who requested it, who reviewed it, when it was deployed, and why. The label shows this bucket is managed by Scalr."

**Key Takeaway**:
> "GitOps workflow: Code → PR → Auto-plan → Policy Check → Review → Merge → Auto-deploy. Scalr's hierarchical governance and policy-as-code make this process scalable across large organizations."

---

## Part 2: Drift Detection (3-4 minutes)

### Talking Points Introduction
*"Even with GitOps, someone might make manual changes during troubleshooting. Scalr's drift detection catches this, and unlike other platforms, gives you three intelligent remediation options."*

### Step 1: Explain Drift
**Say**:
> "Drift happens when infrastructure diverges from what's defined in Git. Someone clicks around in the GCP console, maybe during an outage, and now reality doesn't match code. Scalr detects this and gives you options on how to handle it."

### Step 2: Simulate Manual Change (LIVE ACTION)
**Navigate to**: GCP Console → Cloud Storage → Bucket → Labels

**Actions**:
1. Click "Edit Labels"
2. Add: `manual_change` = `drift_demo`
3. Save

**Say**:
> "I just manually added a label in the GCP console. This label isn't in our Terraform code, so we have drift. Let's see how Scalr detects and handles this."

### Step 3: Trigger Drift Detection (LIVE ACTION)
**Navigate to**: Scalr → Workspace

**Actions**:
1. Click "⋮" menu → "Start Drift Detection Run"
2. Click "Start"

**Say**:
> "Scalr can run drift detection on a schedule or on-demand. It's comparing the actual GCP infrastructure against our Terraform state to find discrepancies. Best part? Drift detection runs are free - they don't count against your run quota."

### Step 4: Review Drift Results
**Wait for completion, then show**:
- Drift detected!
- Plan shows removing the `manual_change` label
- Three remediation options available

**Say**:
> "Scalr found the drift - the manual label we added. Now here's what makes Scalr unique: three remediation options instead of just auto-fix."

### Step 5: Explain Three Remediation Options
**Show the three options in Scalr**:

**Option 1: Ignore Drift**
> "Acknowledge the drift but take no action. Useful when the manual change was intentional and you'll add it to code later."

**Option 2: Sync State**
> "Refresh Terraform state without changing infrastructure. Updates state to match reality. Good for changes you want to keep."

**Option 3: Revert Infrastructure**
> "Apply the plan to remove the manual change and bring infrastructure back to code. Use this for unauthorized changes."

**Say**:
> "This flexibility is key. Not all drift is bad - sometimes emergency changes are necessary. Scalr lets you handle each case appropriately instead of forcing auto-remediation."

**For demo, choose Option 3**:
- Click "Confirm & Apply" to revert
- Show manual label being removed

**Key Takeaway**:
> "Scalr's drift detection with three remediation options gives you control. Infrastructure matches code when it should, but you decide how to handle legitimate exceptions."

---

## Part 3: Policy Enforcement with OPA (5 minutes)

### Talking Points Introduction
*"GitOps plus code review is good, but Scalr goes further with Policy-as-Code. Policies are stored in Git, versioned alongside infrastructure, and Scalr even analyzes policy impact before you deploy changes."*

### Step 1: Show Policy Group Configuration
**Navigate to**: GitHub → `policy/` directory

**What to show**:
- `scalr-policy.hcl` configuration file
- Three `.rego` policy files
- Policy README

**Say**:
> "Our policies live in Git, in the policy directory. The scalr-policy.hcl file configures which policies run and their enforcement levels. This is huge - policy changes go through PRs just like infrastructure changes. Team reviews policy modifications before they're deployed."

**Show scalr-policy.hcl**:
```hcl
policy "require-labels" {
  enabled           = true
  enforcement_level = "hard-mandatory"
  file              = "require-labels.rego"
}
```

**Say**:
> "Three enforcement levels: advisory (warning only), soft-mandatory (can override), hard-mandatory (blocks completely). We can tune each policy based on organizational needs."

### Step 2: Show Policy Group in Scalr
**Navigate to**: Scalr → Settings → Policy Groups

**What to show**:
- `goodrx-demo-policies` Policy Group
- VCS connection to repository
- Attached to environment

**Say**:
> "The Policy Group connects to our repository and reads the policy directory. It's attached at the environment level, so all workspaces in this environment inherit these policies. Hierarchical governance in action."

### Step 3: Explain Policy Violation Scenario
**Walk through hypothetically** (don't actually create):

**Say**:
> "Let me walk you through what happens when someone tries to violate our policies. Say a developer creates a bucket without required labels..."

**Scenario**:
1. **Developer creates non-compliant code**:
   ```hcl
   resource "google_storage_bucket" "bad" {
     name = "my-bucket"
     labels = { name = "my-bucket" }
     # Missing: environment, managed_by!
   }
   ```

2. **Creates PR, Scalr runs automatically**

3. **Policy evaluation**:
   - Pre-plan policies run first (fast feedback)
   - Post-plan policies run after planning (full context)

4. **PR shows failure**:
   ```
   ❌ Policy Failed: require-labels
   GCS bucket 'google_storage_bucket.bad' must have 'environment' label
   GCS bucket 'google_storage_bucket.bad' must have 'managed_by' label
   ```
   - Cannot merge until fixed
   - Clear error messages with resource addresses

5. **Developer fixes, adds labels**

6. **Policy passes, PR can merge**

**Say**:
> "Policies catch violations before deployment. Clear error messages tell developers exactly what's wrong. No manual review needed for compliance - it's automated."

### Step 4: Highlight Policy Impact Analysis (Unique Feature!)
**Navigate to**: Scalr Policy Group (or explain)

**Say**:
> "Here's something unique to Scalr: Policy Impact Analysis. When you change a policy, Scalr tests it against ALL your workspaces before deploying. It shows you which workspaces would be affected and identifies potential issues. This prevents policy changes from breaking existing infrastructure across your organization."

**Benefits**:
- Test policy changes safely
- See impact across all workspaces
- Catch issues before deployment
- Confidence in policy modifications

### Step 5: Show Policy Examples
**Navigate to**: Policy directory files

**Show the three policies**:
1. **require-labels.rego** - Governance
2. **security-best-practices.rego** - Security (prevent public buckets, require uniform access)
3. **cost-optimization.rego** - Cost control (lifecycle rules, storage class, multi-region warnings)

**Say**:
> "We have policies for governance, security, and cost. All written in OPA's Rego language. All versioned in Git. All automatically enforced. You can customize these for your specific needs - compliance frameworks, security standards, cost controls."

**Key Takeaway**:
> "Policy-as-Code in Scalr means: policies stored in Git, versioned with infrastructure, team review of changes, automated enforcement, and Policy Impact Analysis to test changes safely. It's infrastructure governance at scale."

---

## Demo Conclusion (2 minutes)

### Summary

**Say**:
> "Let's recap what Scalr brings to GitOps..."

**Key Points**:

1. **Hierarchical GitOps**:
   - Account → Environment → Workspace structure
   - Share configs across teams
   - Scale governance organization-wide
   - Clear separation of concerns

2. **Intelligent Drift Detection**:
   - Three remediation options (Ignore, Sync, Revert)
   - Free drift detection runs
   - Scheduled or on-demand
   - Handles real-world scenarios

3. **Policy-as-Code**:
   - Policies stored in VCS
   - Policy changes reviewed via PRs
   - Policy Impact Analysis
   - Pre-plan and post-plan evaluation

### Business Benefits

**Say**:
> "For the business, Scalr means..."

- **🔒 Security**: Automated policy enforcement prevents misconfigurations
- **💰 Cost Control**: Policies catch expensive configurations before deployment
- **✅ Compliance**: Complete audit trail, policies enforce standards
- **📈 Scale**: Hierarchical model grows with your organization
- **⚡ Speed**: Automated workflows, clear approval paths
- **👥 Governance**: Environment-level policies, shared configurations

### Scalr vs. Alternatives

**Key Differentiators**:
- **vs Terraform Cloud**: Better policy engine, hierarchical organization, Policy Impact Analysis
- **vs Spacelift**: Policies in VCS (versioned), three drift options, different pricing model
- **vs Env0**: More comprehensive policy framework, better enterprise governance

### Questions to Anticipate

**Q: "How do policies handle emergencies?"**
> A: "Soft-mandatory policies can be overridden with justification. You can also have emergency workspaces without certain policies. Everything's audited."

**Q: "What about secrets?"**
> A: "Variable Sets handle secrets, encrypted at rest. GCP service accounts via JSON key. Integration with HashiCorp Vault and other secret managers."

**Q: "Can we test policy changes safely?"**
> A: "Yes! Policy Impact Analysis tests policy changes against all workspaces before deploying. Shows exactly what would be affected."

**Q: "How much does Scalr cost?"**
> A: "Scalr has a free tier, then scales with usage. Drift detection runs are free. Pricing is competitive with alternatives, and the hierarchical governance often reduces total management overhead."

**Q: "How does Scalr handle large organizations?"**
> A: "The hierarchical model is built for scale. Create environments for teams, share Variable Sets and Policy Groups, manage hundreds of workspaces efficiently."

---

## Backup Scenarios

### Additional: Show Scalr Environment Hierarchy

**Navigate to**: Scalr → Environments

**What to show**:
- Multiple environments (if available)
- Shared Variable Sets
- Shared Policy Groups
- Workspace count per environment

**Say**:
> "Each environment can have multiple workspaces. Variable Sets and Policy Groups attached at environment level are inherited by all workspaces. This makes standardization across teams effortless."

### Additional: Show Run History

**Navigate to**: Workspace → Runs tab

**What to show**:
- Complete run history
- Run details (who triggered, when, why)
- Run outcomes
- Audit trail

---

## Technical Details (For Q&A)

### Workspace Configuration
- **Project**: e360-lab (GCP)
- **Region**: us-west1
- **Backend**: Scalr-managed state
- **Repository**: gitops-goodrx-scalr-demo
- **Environment**: GoodRx GitOps Demo
- **Service Account**: scalr-demo@e360-lab.iam.gserviceaccount.com

### Policy Configuration
- **Policy Group**: goodrx-demo-policies
- **Configuration**: policy/scalr-policy.hcl
- **Enforcement**: hard-mandatory (require-labels, security), soft-mandatory (cost)
- **Storage**: VCS (versioned with infrastructure)

### Key Files
- `terraform/main.tf` - Infrastructure code (managed_by = "scalr")
- `policy/*.rego` - OPA policies (package terraform, input.tfplan)
- `policy/scalr-policy.hcl` - Policy configuration
- `README.md` - Complete setup guide

---

## Post-Demo Actions

- [ ] Share repository link
- [ ] Share Scalr workspace (if appropriate)
- [ ] Offer deep-dive sessions on specific features
- [ ] Provide policy examples for specific use cases
- [ ] Discuss pricing and licensing

---

## Emergency Troubleshooting

### If Scalr doesn't comment on PR:
- Check VCS Provider connection
- Verify workspace trigger settings
- Check GitHub webhook delivery
- Manually trigger run from Scalr

### If drift detection doesn't work:
- Verify manual change was saved
- Check drift detection is enabled
- Ensure workspace has been applied at least once
- Try manual trigger

### If policies don't evaluate:
- Check Policy Group is attached to environment
- Verify scalr-policy.hcl syntax
- Check policy files in correct directory
- Review Policy Group VCS connection

---

## Quick Reference

- **Repository**: gitops-goodrx-scalr-demo
- **PR #1**: (add specific URL after creation)
- **Scalr Dashboard**: https://scalr.io
- **GCP Console**: https://console.cloud.google.com
- **Setup Guide**: README.md

---

**Remember**: The key message is Scalr's hierarchical governance, policies-as-code with Policy Impact Analysis, and intelligent drift remediation make GitOps scalable for large organizations.

**Good luck with your demo! 🚀**
