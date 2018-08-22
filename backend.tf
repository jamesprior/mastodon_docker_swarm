terraform {
  backend "s3" {
    bucket = "kcmo.social"
    key = "terraform/kcmo.social.tfstate"
    region = "us-east-2"
    dynamodb_table = "terraform_locks"
    profile    = "personal"
  }
}