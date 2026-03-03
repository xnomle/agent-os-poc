# Secrets Handling

Never hardcode credentials, tokens, keys, or sensitive values in code.

## Rules

- No secrets in code — not in source files, not in comments, not in defaults
- No `.env` files in git — always add `.env` to `.gitignore`
- Use environment variables for runtime config
- Use secrets managers for production (AWS Secrets Manager, SSM Parameter Store, GitHub Actions secrets)
- OIDC over static keys — for CI/CD auth, always use OIDC

## Local Development

- Use `.env.example` with placeholder values (committed)
- Use `.env` with real values (gitignored)
- Prefer AWS SSO / `aws configure sso` over long-lived keys
- Prefer AWS SSO / `aws configure sso` over long-lived keys

