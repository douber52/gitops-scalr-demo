# GitOps for GoodRx - Scalr Demo

This repository demonstrates GitOps workflows using Scalr for Terraform infrastructure management on Google Cloud Platform (GCP). Follow this guide to set up and run the demo.

## Prerequisites

- [ ] GitHub account with access to create repositories
- [ ] Google Cloud Platform (GCP) account with billing enabled
- [ ] Scalr account (sign up at [scalr.io](https://scalr.io))
- [ ] Terraform installed locally (v1.0+): `brew install terraform` (macOS)
- [ ] Google Cloud SDK installed: `brew install google-cloud-sdk` (macOS)
- [ ] Git installed locally

## Part 1: GCP Setup

### Step 1: Create GCP Project

1. **Go to GCP Console**: https://console.cloud.google.com

2. **Create a new project** (or use existing):
   - Click the project dropdown at the top
   - Click "New Project" (or select existing project)
   - Project name: `gitops-goodrx-demo` or use `e360-lab`
   - Note the Project ID
   - Click "Create"

3. **Enable billing** for the project:
   - Navigate to "Billing" in the menu
   - Link a billing account to your project

### Step 2: Enable Required APIs

1. **Open Cloud Shell** or use your local terminal with `gcloud` installed

2. **Set your project**:
   ```bash
   gcloud config set project YOUR_PROJECT_ID
   ```

3. **Enable required APIs**:
   ```bash
   gcloud services enable cloudresourcemanager.googleapis.com
   gcloud services enable storage-api.googleapis.com
   gcloud services enable iam.googleapis.com
   gcloud services enable iamcredentials.googleapis.com
   ```

### Step 3: Create Service Account for Scalr

1. **Create a service account**:
   ```bash
   gcloud iam service-accounts create scalr-demo \
     --display-name="Scalr Demo Service Account" \
     --description="Service account for Scalr to manage infrastructure"
   ```

2. **Grant necessary permissions**:
   ```bash
   # Get your project ID
   PROJECT_ID=$(gcloud config get-value project)

   # Grant Editor role (for demo purposes - use more restrictive roles in production)
   gcloud projects add-iam-policy-binding $PROJECT_ID \
     --member="serviceAccount:scalr-demo@${PROJECT_ID}.iam.gserviceaccount.com" \
     --role="roles/editor"

   # Grant Storage Admin role
   gcloud projects add-iam-policy-binding $PROJECT_ID \
     --member="serviceAccount:scalr-demo@${PROJECT_ID}.iam.gserviceaccount.com" \
     --role="roles/storage.admin"
   ```

3. **Create and download service account key**:
   ```bash
   gcloud iam service-accounts keys create ~/scalr-key.json \
     --iam-account=scalr-demo@${PROJECT_ID}.iam.gserviceaccount.com
   ```

4. **View the key file** (you'll need this for Scalr):
   ```bash
   cat ~/scalr-key.json
   ```

   **IMPORTANT**: Keep this key file secure. You'll paste its contents into Scalr.

## Part 2: Repository Setup

### Step 4: Set Up GitHub Repository

1. **Create a new GitHub repository**:
   - Go to https://github.com/new
   - Repository name: `gitops-goodrx-scalr-demo`
   - Description: "Scalr GitOps Demo for GoodRx"
   - Make it **Public** (Scalr free tier) or **Private** (if you have paid plan)
   - Do NOT initialize with README, .gitignore, or license
   - Click "Create repository"

2. **Push this code to your new repository**:
   ```bash
   cd gitops-scalr-demo
   git remote add origin https://github.com/YOUR_USERNAME/gitops-goodrx-scalr-demo.git
   git push -u origin main
   ```

### Step 5: Test Terraform Locally

1. **Navigate to terraform directory**:
   ```bash
   cd terraform
   ```

2. **Create a terraform.tfvars file**:
   ```bash
   cat > terraform.tfvars <<EOF
   gcp_project_id = "YOUR_PROJECT_ID"
   gcp_region     = "us-west1"
   environment    = "demo"
   EOF
   ```

3. **Set up GCP credentials locally**:
   ```bash
   # If using Cloud Shell, you're already authenticated
   # If using local terminal:
   gcloud auth application-default login
   ```

4. **Initialize and validate**:
   ```bash
   terraform init
   terraform validate
   terraform fmt
   ```

5. **Run a plan** (don't apply yet):
   ```bash
   terraform plan
   ```

   You should see a plan to create a GCS bucket and related resources.

6. **Return to repo root**:
   ```bash
   cd ..
   ```

## Part 3: Scalr Setup

### Step 6: Create Scalr Account

1. **Go to Scalr**: https://scalr.io

2. **Sign up**:
   - Click "Start Free Trial" or "Sign Up"
   - Choose "Sign up with GitHub" or email
   - Authorize Scalr to access your GitHub account if using GitHub

3. **Create your organization**:
   - Organization name: `goodrx-demo` (or your choice)
   - Click "Create Organization"

### Step 7: Install Scalr GitHub App

1. **In Scalr, navigate to Settings**:
   - Click your organization name (top left)
   - Select "Settings" from sidebar

2. **Set up VCS integration**:
   - In the left menu, click "VCS Providers"
   - Click "Add VCS Provider"
   - Select "GitHub"

3. **Install the GitHub App**:
   - Click "Install GitHub App"
   - You'll be redirected to GitHub
   - Select your GitHub account/organization
   - Choose "Only select repositories"
   - Select your `gitops-goodrx-scalr-demo` repository
   - Click "Install & Authorize"

4. **Verify integration**:
   - You should be redirected back to Scalr
   - Your GitHub connection should now show as "Connected"

### Step 8: Create Environment

**Scalr uses a hierarchy**: Account → Environment → Workspace

1. **Navigate to Environments**:
   - In Scalr, click "Environments" in the left sidebar
   - Click "Create Environment"

2. **Create environment**:
   - **Name**: `GoodRx GitOps Demo`
   - **Description**: "Demo environment for GitOps workflows with Scalr"
   - **Cost Estimation**: Enable if available
   - Click "Create"

### Step 9: Configure GCP Credentials via Variable Sets

1. **Navigate to Variable Sets**:
   - In Scalr Settings (top left), click "Variable Sets"
   - Click "Create Variable Set"

2. **Create Variable Set**:
   - **Name**: `gcp-credentials`
   - **Description**: "GCP service account credentials for demo"
   - **Scope**: Select "Specific Environments"
   - Check "GoodRx GitOps Demo"
   - Click "Continue"

3. **Add environment variables** (click "Add Variable" for each):

   **Variable 1 - GCP Credentials**:
   - Category: **Environment Variable**
   - Key: `GOOGLE_CREDENTIALS`
   - Value: Paste the entire contents of `~/scalr-key.json`
   - Check **"Sensitive"** checkbox (this will encrypt the value)
   - Description: "GCP service account JSON key"
   - Click "Add Variable"

   **Variable 2 - GCP Project**:
   - Category: **Environment Variable**
   - Key: `GOOGLE_PROJECT`
   - Value: Your GCP project ID (e.g., `e360-lab`)
   - Leave "Sensitive" unchecked
   - Description: "GCP project ID"
   - Click "Add Variable"

   **Variable 3 - GCP Region**:
   - Category: **Environment Variable**
   - Key: `GOOGLE_REGION`
   - Value: `us-west1`
   - Leave "Sensitive" unchecked
   - Description: "Default GCP region"
   - Click "Add Variable"

4. **Save the Variable Set**

### Step 10: Create Your First Scalr Workspace

1. **Navigate to your Environment**:
   - Go to Environments → "GoodRx GitOps Demo"
   - Click "Create Workspace"

2. **Configure workspace basics**:
   - **Name**: `goodrx-gitops-demo`
   - **Description**: "GoodRx GitOps demo workspace for GCP Cloud Storage"
   - **Execution Mode**: Remote
   - Click "Continue"

3. **Configure VCS**:
   - **VCS Provider**: Select your GitHub connection
   - **Repository**: Select `gitops-goodrx-scalr-demo`
   - **VCS Branch**: `main` (tracked branch)
   - **Working Directory**: `terraform`
   - Click "Continue"

4. **Configure Triggers**:
   - **Trigger on Pull Request**: ✅ Enabled
   - **Trigger on Commit to Default Branch**: ✅ Enabled
   - **Auto-apply**: ❌ Disabled (manual for demo)
   - **Auto-queue Plans**: ✅ Enabled
   - Click "Continue"

5. **Set Terraform Version**:
   - **Terraform Version**: Select "Latest 1.x" or "1.9.x"
   - Click "Continue"

6. **Add Terraform Variables** (click "Add Variable" for each):
   
   **Variable 1 - Project ID**:
   - Category: **Terraform Variable**
   - Key: `gcp_project_id`
   - Value: Your GCP project ID (e.g., `e360-lab`)
   - HCL: ❌ (it's a string)
   - Click "Add Variable"

   **Variable 2 - Region**:
   - Category: **Terraform Variable**
   - Key: `gcp_region`
   - Value: `us-west1`
   - HCL: ❌
   - Click "Add Variable"

   **Variable 3 - Environment**:
   - Category: **Terraform Variable**
   - Key: `environment`
   - Value: `demo`
   - HCL: ❌
   - Click "Add Variable"

7. **Review and create**:
   - Review all settings
   - Click "Create Workspace"

### Step 11: Configure Policy Group

1. **Navigate to Policy Groups**:
   - Scalr Settings → "Policy Groups"
   - Click "Create Policy Group"

2. **Create Policy Group**:
   - **Name**: `goodrx-demo-policies`
   - **Description**: "OPA policies for GoodRx demo"
   - **VCS Provider**: Select your GitHub connection
   - **Repository**: `gitops-goodrx-scalr-demo`
   - **Path**: `policy`
   - **Branch**: `main`
   - Click "Create"

**Note**: Scalr automatically reads `policy/scalr-policy.hcl` for configuration

3. **Attach to Environment**:
   - Go to Environment "GoodRx GitOps Demo"
   - Click "Policies" tab
   - Click "Attach Policy Group"
   - Select `goodrx-demo-policies`
   - Click "Attach"

### Step 12: Configure Drift Detection

1. **In your Workspace, go to Settings**:
   - Click on workspace "goodrx-gitops-demo"
   - Click "Settings" tab

2. **Configure Drift Detection**:
   - Scroll to "Drift Detection" section
   - **Enable Drift Detection**: ✅
   - **Schedule**: "Daily at 2:00 AM" (or your preference)
   - **Remediation**: Choose your preference:
     - **Ignore Drift**: Acknowledge but take no action
     - **Sync State**: Refresh-only run
     - **Revert Infrastructure**: Apply to fix drift
   - Click "Save Changes"

## Part 4: Demo Workflow

### Step 13: Run Your First Deployment

1. **Navigate to your workspace in Scalr**

2. **Trigger a run**:
   - Click "Start Run" or "Queue Plan" button
   - Reason: "Initial deployment"
   - Click "Start"

3. **Review the run**:
   - Watch the "Initializing" phase
   - Watch the "Planning" phase
   - Review the plan output - you should see resources to create:
     - 1 GCS bucket
     - 1 Storage bucket IAM binding
     - 1 Storage bucket object
     - 1 Random ID
   - **Policy checks run automatically** (pre-plan and post-plan)

4. **Confirm the deployment**:
   - If the plan looks good and policies pass, click "Confirm & Apply" button
   - Add comment: "Initial demo infrastructure"
   - Click "Confirm"
   - Watch the "Applying" phase
   - Wait for completion

5. **Verify in GCP**:
   - Go to GCP Console → Cloud Storage
   - You should see your new bucket: `goodrx-gitops-demo-XXXXXXXX`
   - Check labels include: `managed_by = scalr`

### Step 14: Demo PR Workflow

1. **Create a new branch locally**:
   ```bash
   git checkout -b add-bucket-lifecycle-rule
   ```

2. **Modify `terraform/main.tf`** - Add additional lifecycle rule:

   Add this block after the existing lifecycle rules (around line 57):
   ```hcl
   # Delete very old archived objects
   lifecycle_rule {
     condition {
       age        = 180
       with_state = "ARCHIVED"
     }
     action {
       type = "Delete"
     }
   }
   ```

3. **Commit and push**:
   ```bash
   git add terraform/main.tf
   git commit -m "Add lifecycle rule for old archived objects

   Adds rule to delete objects archived for more than 180 days.
   Helps reduce long-term storage costs."
   git push origin add-bucket-lifecycle-rule
   ```

4. **Create a Pull Request on GitHub**:
   - Go to your GitHub repository
   - Click "Compare & pull request"
   - Title: "Add lifecycle rule for old archived objects"
   - Description: "Adds lifecycle rule to delete archived objects > 180 days old for cost optimization"
   - Click "Create pull request"

5. **Watch Scalr comment on the PR**:
   - Within 1-2 minutes, Scalr will comment with:
     - Summary of the proposed run
     - Workspace information
     - Resource changes (1 update to bucket)
     - Policy results (all passed)
     - Cost impact (if enabled)
     - Link to full run in Scalr
   - GitHub status check will show "Scalr"

6. **Review the plan in Scalr**:
   - Click the Scalr link in the PR comment
   - Review the detailed plan
   - See that the bucket will be updated with new lifecycle rule
   - Policy checks pass ✅

7. **Merge the PR**:
   - If the plan looks good, approve and merge the PR on GitHub
   - Click "Merge pull request"
   - Confirm merge

8. **Apply changes in Scalr**:
   - Scalr will automatically create a new run on `main` branch
   - Go to your workspace in Scalr
   - Review the new run
   - Click "Confirm & Apply" to deploy
   - Watch the lifecycle rule get added

### Step 15: Demo Drift Detection

**Drift detection shows when infrastructure is modified outside of Terraform.**

#### 15.1: Manually Change Infrastructure

1. **Go to GCP Console**:
   - Navigate to Cloud Storage
   - Click on your demo bucket

2. **Add a label manually**:
   - Click "Labels" tab
   - Click "Edit Labels" or "Add Label"
   - Key: `manual_change`
   - Value: `drift_demo`
   - Click "Save"

#### 15.2: Trigger Drift Detection in Scalr

1. **In Scalr, go to your workspace**

2. **Trigger drift detection**:
   - Click the "⋮" (three dots menu) at top right
   - Select "Start Drift Detection Run"
   - Click "Start"

3. **Review drift results**:
   - Wait for the drift detection to complete
   - Click on the drift detection run
   - Review the changes:
     - Scalr will show the manually added label
     - The plan will show removing the `manual_change` label

4. **Remediate drift** - Choose one of Scalr's three options:

   **Option A: Ignore Drift**
   - Acknowledge the drift but take no action
   - Useful for intentional manual changes

   **Option B: Sync State**
   - Refresh Terraform state only
   - Doesn't change infrastructure
   - Updates state to match reality

   **Option C: Revert Infrastructure**
   - Click "Confirm & Apply" to remove the manual change
   - This brings infrastructure back to the desired state defined in Git
   - Recommended for unauthorized changes

### Step 16: Demo Policy Enforcement with OPA

**Policies enforce organizational standards on infrastructure changes.**

#### 16.1: Policy Group Overview

Your policies are already configured via:
- **Policy Group**: `goodrx-demo-policies`
- **Configuration File**: `policy/scalr-policy.hcl`
- **Policies**: `require-labels.rego`, `security-best-practices.rego`, `cost-optimization.rego`

**Key Feature**: Policies are stored in VCS and versioned with your infrastructure!

#### 16.2: Walkthrough Policy Violation Scenario

**Scenario**: Developer tries to create a bucket without required labels

1. **Create violating code** (demonstration only - don't actually do this):
   ```hcl
   resource "google_storage_bucket" "non_compliant" {
     name     = "non-compliant-bucket-${random_id.bucket_suffix.hex}"
     location = var.gcp_region
     
     labels = {
       name = "non-compliant-bucket"
       # Missing: environment, managed_by labels!
     }
   }
   ```

2. **Create PR with non-compliant code**:
   - Push to branch, create PR
   - Scalr automatically runs plan

3. **Policy evaluation**:
   - **Pre-plan policies**: Run before planning
   - **Post-plan policies**: Run after planning
   - Both sets evaluated automatically

4. **PR shows failure**:
   - Scalr run shows **FAILED** status
   - Policy violations clearly listed:
     ```
     ❌ Policy Failed: require-labels
     GCS bucket 'google_storage_bucket.non_compliant' must have 'environment' label
     GCS bucket 'google_storage_bucket.non_compliant' must have 'managed_by' label
     
     ⚠️ Warning: require-labels
     GCS bucket 'google_storage_bucket.non_compliant' should have 'owner' label
     ```
   - GitHub status check shows failure
   - Cannot apply until fixed

5. **Developer fixes code**:
   ```hcl
   resource "google_storage_bucket" "non_compliant" {
     name     = "now-compliant-bucket-${random_id.bucket_suffix.hex}"
     location = var.gcp_region
     
     labels = {
       name        = "now-compliant-bucket"
       environment = "demo"        # ✅ Added
       managed_by  = "scalr"       # ✅ Added
       owner       = "demo-team"   # ✅ Optional but recommended
     }
   }
   ```

6. **Push fix, Scalr re-runs**:
   - Policy checks pass ✅
   - Run shows "Unconfirmed" status (ready to apply)
   - PR can now be merged

#### 16.3: Policy Impact Analysis (Scalr Unique Feature)

**Test policy changes before deploying**:

1. **Modify a policy** in `policy/*.rego`
2. **Create PR** with policy change
3. **Scalr analyzes impact**:
   - Tests new policy against all workspaces
   - Shows which workspaces would be affected
   - Identifies potential issues before deployment
4. **Review impact** before merging

This prevents policy changes from breaking existing infrastructure!

## Demo Script Summary

Here's your complete demo flow:

1. **Introduction** (2 min) - Show repository structure, explain GitOps
2. **PR Workflow** (5 min) - Create PR, show Scalr plan, merge, apply
3. **Drift Detection** (4 min) - Manual change, detect, three remediation options
4. **Policy Enforcement** (5 min) - Explain Policy Groups, show violation scenario, Policy Impact Analysis

## Cleanup

### Remove Infrastructure

1. **Destroy resources via Scalr**:
   - Go to your workspace
   - Click "⋮" → "Destroy Resources"
   - Reason: "Demo cleanup"
   - Review destroy plan
   - Type workspace name to confirm
   - Click "Destroy"

2. **Delete the workspace**:
   - After resources are destroyed
   - Go to workspace Settings
   - Scroll to bottom → "Danger Zone"
   - Click "Delete Workspace"
   - Confirm deletion

3. **Delete Environment** (optional):
   - Go to Environment settings
   - Delete environment if no longer needed

### Remove GCP Resources

1. **Delete service account**:
   ```bash
   PROJECT_ID=$(gcloud config get-value project)
   gcloud iam service-accounts delete scalr-demo@${PROJECT_ID}.iam.gserviceaccount.com
   ```

2. **Delete service account key**:
   ```bash
   rm ~/scalr-key.json
   ```

3. **Delete GCP project** (optional):
   ```bash
   gcloud projects delete YOUR_PROJECT_ID
   ```

## Troubleshooting

### Scalr can't access repository
- Verify GitHub App is installed and has access to your repository
- Go to GitHub Settings → Applications → Scalr
- Check repository access
- Re-authorize connection in Scalr VCS Providers

### "Invalid credentials" error
- Verify `GOOGLE_CREDENTIALS` in Variable Set is valid JSON
- Verify service account exists in GCP
- Check that `GOOGLE_PROJECT` matches your actual project ID
- Ensure Variable Set is attached to your environment

### Plan fails with "API not enabled"
- Ensure all required APIs are enabled in GCP
- Run the enable commands from Step 2
- Wait a few minutes for API enablement to propagate

### Drift detection shows no drift
- Ensure you made a manual change in GCP Console
- Verify the bucket exists and change was saved
- Wait a few minutes for GCP to sync
- Check drift detection is enabled for workspace

### Policy doesn't trigger
- Verify Policy Group is attached to environment
- Check `scalr-policy.hcl` exists in `policy/` directory
- Review policy syntax in Scalr Policy Group
- Ensure VCS connection is working
- Check Policy Group is reading from correct branch

### Workspace doesn't trigger on PR
- Verify "Trigger on Pull Request" is enabled
- Check VCS webhook exists in GitHub repo settings
- Review Scalr run history for errors
- Manually trigger run to test

### Variables not available
- Check Variable Set is attached to environment
- Verify workspace is in correct environment
- Check variable categories (Environment vs Terraform)
- Review variable scoping

## Scalr-Specific Features

### Hierarchical Governance
- **Account** → **Environment** → **Workspace** hierarchy
- Share configurations across teams via environments
- Centralized policy management
- Environment-level Variable Sets

### Policy Groups in VCS
- Policies stored in Git and versioned
- Policy changes go through PRs
- Team review of policy modifications
- Policy Impact Analysis before deployment

### Three Drift Remediation Options
Unlike other platforms with single auto-remediate:
1. **Ignore Drift** - Acknowledge intentional changes
2. **Sync State** - Update state without changing infrastructure
3. **Revert Infrastructure** - Apply to fix drift

### Free Drift Detection
- Drift detection runs don't count against run quota
- Schedule drift checks without worry
- Regular compliance verification

### Pre-plan and Post-plan Policies
- **Pre-plan**: Evaluated before planning (faster feedback)
- **Post-plan**: Evaluated after planning (full plan context)
- More control over policy execution timing

## Additional Resources

- [Scalr Documentation](https://docs.scalr.io)
- [Terraform GCP Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [Open Policy Agent](https://www.openpolicyagent.org/docs/latest/)
- [Scalr Policy Documentation](https://docs.scalr.io/docs/policy-as-code)
- [GCP IAM Best Practices](https://cloud.google.com/iam/docs/best-practices)
- [Scalr vs Other Platforms](https://scalr.com/learning-center/)
