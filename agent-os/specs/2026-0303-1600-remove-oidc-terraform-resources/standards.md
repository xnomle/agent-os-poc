# Standards

## global/secrets-handling

Never hardcode credentials, tokens, keys, or sensitive values in code.

### Rules

- No secrets in code — not in source files, not in comments, not in defaults
- No `.env` files in git — always add `.env` to `.gitignore`
- Use environment variables for runtime config
- Use secrets managers for production (AWS Secrets Manager, SSM Parameter Store, GitHub Actions secrets)
- OIDC over static keys — for CI/CD auth, always use OIDC

### Local Development

- Use `.env.example` with placeholder values (committed)
- Use `.env` with real values (gitignored)
- Prefer AWS SSO / `aws configure sso` over long-lived keys

---

## global/commit-conventions

All commits use Conventional Commits format.
```
<type>(<scope>): <short description>
```

Types: `feat`, `fix`, `docs`, `chore`, `refactor`, `test`, `ci`, `style`

- Scope is optional but encouraged
- Description is lowercase, no period
- Breaking changes: add `!` after type/scope

Examples:
```
feat(api): add hello world POST endpoint
fix(lambda): correct region to ap-southeast-2
ci(github-actions): add OIDC authentication
docs: update product plan with OIDC requirement
```

---

## global/branch-naming

All branches follow this format:
```
<type>/<short-kebab-description>
```

Types: `feat`, `fix`, `chore`, `docs`, `refactor`, `test`, `ci`

- Always kebab-case after the prefix
- Keep it short but descriptive
- No uppercase, no underscores
- Never commit directly to `main`. Always branch and PR.
