# Terraform Remote State + CI Pipeline Improvements

## Context

Terraform state is currently written to the ephemeral GitHub Actions runner filesystem (local backend). Every workflow run has no prior state, risking duplicate resource creation and drift. The CI pipeline also has no linting, no plan review step, and applies immediately on push to main with no gate. This change adds persistent S3 remote state with native locking (no DynamoDB), a tflint lint step, and a plan → manual gate → apply workflow.

---

## Task 1: Save Spec Documentation

Create `agent-os/specs/2026-03-03-1200-terraform-remote-state-ci-pipeline/` with:
- `plan.md` — this full plan
- `shape.md` — shaping notes
- `standards.md` — secrets-handling standard content
- `references.md` — N/A (no existing references)

---

## Task 2: Add S3 Backend Configuration

**Create `infra/backend.tf`:**
```hcl
terraform {
  backend "s3" {
    bucket       = "agent-os-poc"
    key          = "terraform.tfstate"
    region       = "ap-southeast-2"
    encrypt      = true
    use_lockfile = true
  }
}
```

**Modify `infra/provider.tf`** — add `required_version` to existing terraform block:
```hcl
terraform {
  required_version = ">= 1.10.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```

**Key facts:**
- `use_lockfile = true` requires Terraform >= 1.10.0 (GA in 1.11). Writes `.tfstate.tflock` to the same S3 bucket — no DynamoDB needed.
- AWS provider version has no additional requirement (backend is a Terraform core feature).
- Current locked provider is 5.100.0 — compatible.

---

## Task 3: Add tflint Configuration

**Create `.tflint.hcl`** in repo root:
```hcl
plugin "aws" {
  enabled = true
  version = "0.38.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}
```

---

## Task 4: Restructure GitHub Actions Workflow

**Modify `.github/workflows/deploy.yml`** — split into three jobs:

- `lint`: runs tflint
- `plan`: needs lint, runs terraform plan, uploads artifact
- `apply`: needs plan, uses `environment: production` for manual gate, downloads artifact and applies

**Gate mechanism:** The `apply` job uses `environment: production`. Create a `production` environment in GitHub repo Settings → Environments → Add environment → enable "Required reviewers". The apply job will pause and wait for manual approval before proceeding.

---

## Files Changed

| File | Action |
|---|---|
| `infra/backend.tf` | Create |
| `infra/provider.tf` | Modify (add required_version) |
| `.tflint.hcl` | Create |
| `.github/workflows/deploy.yml` | Modify (lint + plan + apply jobs) |
| `agent-os/specs/2026-03-03-1200-terraform-remote-state-ci-pipeline/` | Create (spec docs) |

---

## Verification

1. Push to `main` → workflow triggers
2. **Lint job** passes (tflint finds no issues)
3. **Plan job** runs: S3 bucket is created/verified, `terraform plan` output visible in Actions logs, `tfplan` artifact uploaded
4. **Apply job** pauses — GitHub shows "Waiting for approval" on the `production` environment
5. Approve in GitHub UI → apply runs using the saved plan artifact
6. Confirm state file exists: `aws s3 ls s3://agent-os-poc/terraform.tfstate`
7. Confirm lock file behaviour: during apply, check `s3://agent-os-poc/terraform.tfstate.tflock` exists transiently
