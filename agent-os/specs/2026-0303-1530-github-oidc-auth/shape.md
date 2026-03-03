# GitHub OIDC Auth — Shaping Notes

## Scope

Replace long-lived static AWS credentials in GitHub Actions with OIDC-based authentication. Instead of storing `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` as GitHub secrets, the workflow will assume an IAM role using a short-lived JWT issued by GitHub.

## Decisions

- **OIDC over static credentials** — eliminates stored secrets, tokens expire automatically, trust is scoped to this specific repo
- **`AdministratorAccess` policy on the GitHub Actions role** — appropriate for this POC; should be scoped to specific services (Lambda, API Gateway, IAM) before production
- **Trust policy uses `StringLike` for `sub`** — allows the role to be assumed from any ref (branch, tag, PR) in the repo; can be tightened to `repo:personal/agent-os-poc:ref:refs/heads/main` if desired
- **Thumbprint hardcoded** — GitHub's OIDC thumbprint `6938fd4d98bab03faadb97b34396831e3780aea1` is well-known and stable; avoids adding the `tls` Terraform provider
- **Region hardcoded to `ap-southeast-2`** — matches the existing `variables.tf` default

## Context

- **Visuals:** None
- **References:** No existing OIDC setup in this repo
- **Product alignment:** N/A — pure infrastructure security improvement
- **Standards applied:** global/secrets-handling, global/commit-conventions, global/branch-naming

## Bootstrapping Constraint

OIDC resources must exist in AWS before the workflow can use them. First apply must be run locally with existing AWS credentials. This is a one-time step.
