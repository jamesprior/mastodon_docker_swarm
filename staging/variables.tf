# These should be set in secrets.auto.tfvars

# provider setup
variable "do_token" {}
variable "do_droplan_token" {}
variable "aws_access_key" { default = "" }
variable "aws_secret_key" { default = "" }
variable "aws_profile" { }
variable "aws_region" { default = "us-east-2" }

# mastodon env secrets
variable "vapid_public_key" { }
variable "vapid_private_key" { }
variable "smtp_login" { }
variable "smtp_password" { }
variable "aws_access_key_id" { }
variable "aws_secret_access_key" { }
variable "backup_aws_access_key_id" { }
variable "backup_aws_secret_access_key" { }
