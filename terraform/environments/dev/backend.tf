terraform {
  backend "s3" {
    bucket       = "petclinic-terraform-state-400294418932"
    key          = "petclinic/dev/terraform.tfstate"
    region       = "eu-central-1"
    use_lockfile = true
    encrypt      = true
  }
}
