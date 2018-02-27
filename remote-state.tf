# Manage the remote state file storage on S3 for Terraform 
terraform {
  backend "s3" {
    bucket = "bbt-terraform"
    key    = "path/to/state/file"
    region = "eu-west-1"
  }
}