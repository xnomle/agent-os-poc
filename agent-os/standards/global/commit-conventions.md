# Commit Conventions

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
