# Plan: Lambda POST Endpoint MVP

## Context

This is the MVP proof-of-concept for the agent-os-poc project — a demonstration of spec-driven AI development. The goal is a minimal but fully deployed AWS backend: a single Python Lambda function exposed via API Gateway that returns `200 "Hello World"` on POST, with Terraform managing the infrastructure and GitHub Actions handling CI/CD on push to `main`.

---

## Task 1: Save Spec Documentation

Create `agent-os/specs/2026-0303-1500-lambda-post-endpoint-mvp/` containing:

- **plan.md** — this plan
- **shape.md** — shaping notes (scope, decisions, context)
- **standards.md** — note that no standards currently apply (index.yml is empty)
- **references.md** — no existing code references (fresh project)

---

## Task 2: Create Python Lambda Function

**File:** `src/handler.py`

```python
import json

def lambda_handler(event, context):
    return {
        "statusCode": 200,
        "body": json.dumps("Hello World")
    }
```

- Keep the handler minimal and flat — no extra dependencies
- Module path: `handler.lambda_handler` (used in Terraform)

---

## Task 3: Create Terraform Infrastructure

**Directory:** `infra/`

Key resources to define in `infra/main.tf`:

1. **`aws_iam_role`** — Lambda execution role with `AWSLambdaBasicExecutionRole` policy
2. **`aws_lambda_function`** — Points to zipped `src/` package, runtime `python3.12`, handler `handler.lambda_handler`
3. **`aws_apigatewayv2_api`** — HTTP API (not REST API — simpler, cheaper)
4. **`aws_apigatewayv2_integration`** — Lambda proxy integration
5. **`aws_apigatewayv2_route`** — `POST /` route
6. **`aws_apigatewayv2_stage`** — `$default` stage with auto-deploy enabled
7. **`aws_lambda_permission`** — Allow API Gateway to invoke the Lambda

**File:** `infra/variables.tf` — `aws_region` variable (default `ap-southeast-2`)
**File:** `infra/outputs.tf` — Output the API Gateway invoke URL
**File:** `infra/provider.tf` — AWS provider block

**State:** Use local state for the POC (no remote backend needed).

---

## Task 4: Create GitHub Actions CI/CD Pipeline

**File:** `.github/workflows/deploy.yml`

Trigger: `push` to `main`

Steps:
1. Checkout code
2. Set up Python 3.12
3. Zip the Lambda source: `zip -j lambda.zip src/handler.py`
4. Set up Terraform (use `hashicorp/setup-terraform` action)
5. `terraform init` (in `infra/`)
6. `terraform apply -auto-approve` (pass `lambda_zip_path` variable pointing to `../lambda.zip`)

**Required GitHub secrets:**
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_REGION` (or hardcode `ap-southeast-2`)

Terraform needs the zip path as a variable so the Lambda resource can reference the built artifact:
- `infra/variables.tf` includes `lambda_zip_path` variable
- `aws_lambda_function` uses `filename = var.lambda_zip_path`

---

## Task 5: Smoke Test (Manual Verification)

After deploy:

1. Capture the API Gateway URL from Terraform output
2. Run: `curl -X POST <invoke_url>`
3. Expected response: `"Hello World"` with HTTP 200

---

## File Layout After Implementation

```
.
├── src/
│   └── handler.py
├── infra/
│   ├── main.tf
│   ├── provider.tf
│   ├── variables.tf
│   └── outputs.tf
├── .github/
│   └── workflows/
│       └── deploy.yml
└── agent-os/
    └── specs/
        └── 2026-0303-1500-lambda-post-endpoint-mvp/
            ├── plan.md
            ├── shape.md
            ├── standards.md
            └── references.md
```

---

## Verification

- `curl -X POST <api_gateway_url>` returns `"Hello World"` with status 200
- GitHub Actions workflow run shows green on push to `main`
- Terraform outputs the invoke URL after apply
