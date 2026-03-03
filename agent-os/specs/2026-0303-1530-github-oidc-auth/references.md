# References: GitHub OIDC Auth

## Existing Code References

None — this is the first OIDC setup in this repository.

## Files Being Modified

- `.github/workflows/deploy.yml` — existing GitHub Actions workflow using static credentials
- `infra/main.tf` — existing Terraform resources (Lambda, API Gateway, IAM)
- `infra/variables.tf` — existing Terraform variables
- `infra/outputs.tf` — existing Terraform outputs

## External References

- [GitHub docs: Configuring OpenID Connect in Amazon Web Services](https://docs.github.com/en/actions/security-for-github-actions/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services)
- [aws-actions/configure-aws-credentials](https://github.com/aws-actions/configure-aws-credentials)
- [Terraform `aws_iam_openid_connect_provider` resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider)
