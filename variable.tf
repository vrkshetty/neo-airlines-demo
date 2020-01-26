variable "REGION" {
  type    = "string"
  default = "eu-central-1"
}
variable "PREFIX" {
  type    = "string"
  default = "neo-eks"
}
variable "VPC_NAME" {
  type    = "string"
  default = "neo-eks"
}
variable "VPC_CIDR" {
  type    = "string"
  default = "192.168.0.0/16"
}
variable "SUBNET_AZ1_NAME" {
  type    = "string"
  default = "neo-snet-az-a"
}
variable "SUBNET_AZ1_CIDR" {
  type    = "string"
  default = "192.168.64.0/18"
}
variable "SUBNET_AZ2_NAME" {
  type    = "string"
  default = "neo-snet-az-b"
}
variable "SUBNET_AZ2_CIDR" {
  type    = "string"
  default = "192.168.128.0/18"
}
variable "cluster-name" {
  type    = "string"
  default = "neo-eks-cluster"
}

variable "aws_profile" {
  type    = "string"
  default = "default"
}
variable "ssh_key_name" {
  type    = "string"
  default = "my-key"
}
