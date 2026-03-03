# Shape Notes

## Problem

Terraform state is stored on ephemeral GitHub Actions runner filesystem. Every CI run starts with no state, causing:
- Duplicate resource creation risk
- No drift detection
- No history of infrastructure changes

The CI pipeline applies immediately on push to main with no lint step, no plan review, and no manual gate.

## Appetite

Small — isolated to infra config and CI workflow files. No application code changes.

## Solution

### Remote State
Use S3 backend with native lock file support (`use_lockfile = true`). This eliminates the DynamoDB dependency while providing state locking via a `.tflock` file in the same bucket.

Requires Terraform >= 1.10.0 (lockfile feature GA in 1.11).

### CI Pipeline
Split single `deploy` job into three sequential jobs:
1. `lint` — tflint with AWS ruleset
2. `plan` — terraform plan, upload artifact
3. `apply` — manual gate via GitHub environment, download artifact, apply

### Decisions Made
- **No DynamoDB**: `use_lockfile = true` provides locking natively in S3. Simpler, fewer resources.
- **S3 bucket bootstrap in CI**: `aws s3api create-bucket` with `|| true` guard handles idempotency without a chicken-and-egg problem.
- **tflint AWS plugin v0.38.0**: Latest stable at time of writing.
- **`environment: production`**: Standard GitHub mechanism for manual approval gates. Requires repo Settings configuration.

## Rabbit Holes (Out of Scope)
- Separate state per environment (single env for now)
- Terraform Cloud / remote execution
- Cost estimation in CI
- Slack notifications on apply
