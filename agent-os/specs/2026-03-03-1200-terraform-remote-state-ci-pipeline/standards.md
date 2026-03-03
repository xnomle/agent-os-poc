# Standards: Secrets Handling in CI

## Applicable Standard

All secrets used in GitHub Actions workflows must follow the project secrets-handling standard.

## Requirements Met

### AWS Credentials
- AWS access is via OIDC role assumption (`aws-actions/configure-aws-credentials@v4`)
- No long-lived AWS access keys stored as secrets
- Role ARN stored as `AWS_OIDC_ROLE` repository secret
- Role is scoped to minimum required permissions for the workflow

### Terraform State
- S3 bucket encryption enabled (`encrypt = true` in backend config)
- State file access governed by the OIDC role's IAM permissions
- No secrets stored in Terraform state (state contains resource metadata only)

### No New Secrets Introduced
This change does not introduce any new secrets beyond the existing `AWS_OIDC_ROLE`.

## GitHub Environment Protection
The `production` environment gate does not store secrets — it provides approval control only. Reviewers must be configured in GitHub Settings → Environments → production → Required reviewers.
