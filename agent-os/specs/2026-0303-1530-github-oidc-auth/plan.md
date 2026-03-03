# Plan: Replace Static AWS Credentials with GitHub OIDC Auth

## Context

The current GitHub Actions deploy workflow authenticates to AWS using long-lived static credentials (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`) stored as GitHub secrets. These are a security liability — they never expire and grant broad access regardless of context.

GitHub Actions supports OIDC (OpenID Connect), which lets the workflow exchange a short-lived GitHub-issued JWT for temporary AWS credentials by assuming an IAM role. No static credentials are stored anywhere.

This change replaces static credentials with OIDC across the Terraform infrastructure and the CI/CD workflow.

---

## Bootstrapping Note (Important)

There is a chicken-and-egg problem: the OIDC provider and IAM role must exist in AWS *before* the GitHub Actions workflow can use OIDC. The first apply must be done locally using existing AWS credentials (`aws configure` or env vars). Once the OIDC resources are live, subsequent CI runs authenticate via OIDC.

---

## Task 1: Save Spec Documentation

Create `agent-os/specs/2026-0303-1530-github-oidc-auth/` with:

- **plan.md** — this plan
- **shape.md** — shaping notes
- **standards.md** — no standards apply
- **references.md** — no existing code references

---

## Task 2: Add OIDC Terraform Resources

### `infra/variables.tf`

Add a new variable:

```hcl
variable "github_repo" {
  description = "GitHub repo in owner/name format (used in OIDC trust policy)"
  type        = string
  default     = "personal/agent-os-poc"
}
```

### `infra/main.tf`

Append three new resources:

```hcl
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

resource "aws_iam_role" "github_actions" {
  name = "github-actions-deploy"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = aws_iam_openid_connect_provider.github.arn }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
        StringLike = {
          "token.actions.githubusercontent.com:sub" = "repo:${var.github_repo}:*"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "github_actions_admin" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
```

> **Note:** `AdministratorAccess` is appropriate for this POC. Scope to specific IAM actions before production use.

### `infra/outputs.tf`

Add output for the role ARN (needed to set the `AWS_ROLE_ARN` GitHub secret):

```hcl
output "github_actions_role_arn" {
  description = "IAM role ARN for GitHub Actions OIDC authentication"
  value       = aws_iam_role.github_actions.arn
}
```

---

## Task 3: Bootstrap OIDC Resources (One-Time Manual Step)

Run locally with static AWS credentials:

```bash
cd infra
terraform init
terraform apply
```

Capture the role ARN and add it as a GitHub Actions secret named `AWS_ROLE_ARN`:

```bash
terraform output github_actions_role_arn
```

---

## Task 4: Update GitHub Actions Workflow

**File:** `.github/workflows/deploy.yml`

Changes:
1. Add `permissions` block (`id-token: write`, `contents: read`) at job level
2. Add `aws-actions/configure-aws-credentials@v4` step using `role-to-assume`
3. Remove all static-credential `env` vars

---

## Task 5: Clean Up Old Secrets

Remove from GitHub repo secrets:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_REGION`

---

## Verification

1. After Task 3 bootstrap: `terraform output github_actions_role_arn` returns a valid ARN
2. Add `AWS_ROLE_ARN` secret to GitHub repo
3. Push to `main` — GitHub Actions workflow run shows green
4. "Configure AWS credentials" step logs show assumed role ARN (no static key IDs)
5. Smoke test: `curl -X POST $(terraform output -raw invoke_url)` returns `"Hello World"`
