# Shape: Remove Redundant OIDC Terraform Resources

## Problem

The Terraform code contains three resources (`aws_iam_openid_connect_provider.github`, `aws_iam_role.github_actions`, `aws_iam_role_policy_attachment.github_actions_admin`) that provisioned the GitHub Actions OIDC integration. These resources have already been applied and are live in AWS. The role ARN is now stored as `AWS_OIDC_ROLE` in GitHub repo secrets and the workflow uses it directly.

Keeping these resources in Terraform creates risk: a future `terraform apply` could drift, recreate, or delete them if state is lost or mismatched. They should be removed from the codebase entirely.

## Appetite

Small — pure deletion, no new logic. Three resource blocks, one variable, one output.

## Solution

Delete the three OIDC resource blocks from `infra/main.tf`, the `github_repo` variable from `infra/variables.tf`, and the `github_actions_role_arn` output from `infra/outputs.tf`. No other files change.

## Out of Scope

- Importing the resources into Terraform state (not needed — they are intentionally unmanaged)
- Modifying the GitHub Actions workflow (already correct)
- Changing the IAM role or OIDC provider in AWS
