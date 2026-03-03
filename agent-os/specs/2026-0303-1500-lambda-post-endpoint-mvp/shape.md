# Shape: Lambda POST Endpoint MVP

## Problem

We need a minimal deployed AWS backend to demonstrate spec-driven AI development with the agent-os-poc project.

## Appetite

Small — MVP scope only. Single Lambda, single route, no auth, no database, no error handling beyond the happy path.

## Solution

A Python Lambda function behind API Gateway HTTP API, deployed via Terraform, with GitHub Actions CI/CD.

## Scope

### In
- Single Python Lambda returning `"Hello World"` on `POST /`
- API Gateway HTTP API (v2) — simpler and cheaper than REST API
- Terraform for infrastructure (local state — no remote backend for POC)
- GitHub Actions deploy pipeline on push to `main`

### Out
- Authentication / authorization
- Custom domain
- Multiple routes or methods
- Database or state
- Remote Terraform state (S3/DynamoDB)
- Unit tests or integration tests
- Monitoring / alerting

## Key Decisions

1. **HTTP API (v2) over REST API (v1)** — lower cost, simpler configuration, sufficient for this use case
2. **Local Terraform state** — acceptable for a single-developer POC; no need for locking
3. **`python3.12` runtime** — current LTS, no external dependencies needed
4. **Inline zip in CI** — zip the handler file directly; no build step required for pure-Python with stdlib only
5. **`$default` stage with auto-deploy** — avoids manual stage deployment step

## Risks / Notes

- Local Terraform state means state is not shared between machines or CI runs; this is acceptable for a POC but would need to change before production use
- The GitHub Actions workflow uses `terraform apply -auto-approve` — appropriate for a POC, not for production
