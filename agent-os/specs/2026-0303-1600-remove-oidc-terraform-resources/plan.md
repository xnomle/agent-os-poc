# Plan: Remove Redundant OIDC Terraform Resources

## Context

The OIDC IAM role and provider have already been provisioned in AWS. The role ARN is stored as `AWS_OIDC_ROLE` in GitHub repo secrets, and the GitHub Actions workflow (`deploy.yml`) already uses it correctly via `role-to-assume: ${{ secrets.AWS_OIDC_ROLE }}`.

The Terraform code in `infra/main.tf` still contains the three resources that created those OIDC AWS resources. Since they are no longer managed by this repo's Terraform (they exist externally), keeping them risks drift or accidental deletion. They should be removed, along with the `github_repo` variable and `github_actions_role_arn` output that existed solely to support them.

---

## Standards Applied

- **global/secrets-handling** — OIDC over static keys; no credentials in code
- **global/commit-conventions** — conventional commits format
- **global/branch-naming** — branch and PR; never commit to `main`

---

## Task 1: Save Spec Documentation

Create `agent-os/specs/2026-0303-1600-remove-oidc-terraform-resources/` with:

- **plan.md** — this plan
- **shape.md** — shaping notes
- **standards.md** — full content of applicable standards
- **references.md** — pointer to previous OIDC spec

---

## Task 2: Remove OIDC Resources from `infra/main.tf`

**File:** `infra/main.tf`

Remove the following three resource blocks (lines approx 46–80):

```hcl
resource "aws_iam_openid_connect_provider" "github" { ... }
resource "aws_iam_role" "github_actions" { ... }
resource "aws_iam_role_policy_attachment" "github_actions_admin" { ... }
```

These are the only OIDC-related resources in `main.tf`. The remaining Lambda and API Gateway resources are unaffected.

---

## Task 3: Remove `github_repo` Variable from `infra/variables.tf`

**File:** `infra/variables.tf`

Remove the `github_repo` variable block — it was only referenced in the OIDC trust policy condition, which no longer exists.

---

## Task 4: Remove `github_actions_role_arn` Output from `infra/outputs.tf`

**File:** `infra/outputs.tf`

Remove the `github_actions_role_arn` output block — it referenced `aws_iam_role.github_actions.arn`, which is being removed.

---

## Files Modified

- `infra/main.tf` — removed 3 OIDC resource blocks
- `infra/variables.tf` — removed `github_repo` variable
- `infra/outputs.tf` — removed `github_actions_role_arn` output
- `agent-os/specs/2026-0303-1600-remove-oidc-terraform-resources/` — new spec folder (created)

---

## Verification

1. `infra/main.tf` no longer contains `aws_iam_openid_connect_provider`, `aws_iam_role.github_actions`, or `aws_iam_role_policy_attachment.github_actions_admin`
2. `infra/variables.tf` no longer contains `github_repo`
3. `infra/outputs.tf` no longer contains `github_actions_role_arn`
4. `terraform validate` passes (no references to removed resources)
5. The workflow (`deploy.yml`) is unchanged — it still uses `secrets.AWS_OIDC_ROLE`
