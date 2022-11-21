provider "digitalocean" {
  token   = var.do_token
  version = "1.3"
}

provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.aws_region
  profile    = var.aws_profile
  version    = "~> 2.42"
}

