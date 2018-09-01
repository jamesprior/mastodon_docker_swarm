terraform {
  backend "s3" {
    bucket = "tfstate.jamesior"
    key = "kcmo.social-staging.tfstate"
    region = "us-east-2"
    dynamodb_table = "terraform_locks"
    profile    = "personal"
  }
}