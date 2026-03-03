terraform {
  backend "s3" {
    bucket       = "agent-os-poc"
    key          = "terraform.tfstate"
    region       = "ap-southeast-2"
    encrypt      = true
    use_lockfile = true
  }
}
