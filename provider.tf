provider "aws" {
  region                  = "${var.REGION}"
  shared_credentials_file = "~/.aws/creds"
  profile                 = "${var.aws_profile}"
}
