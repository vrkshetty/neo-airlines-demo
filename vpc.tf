resource "aws_vpc" "main_vpc" {
  cidr_block           = "${var.VPC_CIDR}"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.PREFIX}-VPC"

  }
}
resource "aws_subnet" "subnet_az_1" {
  vpc_id            = "${aws_vpc.main_vpc.id}"
  cidr_block        = "${var.SUBNET_AZ1_CIDR}"
  availability_zone = "${var.REGION}a"
  tags = "${
    map(
      "Name", "${var.SUBNET_AZ1_NAME}",
      "kubernetes.io/cluster/${var.cluster-name}", "owned",
      "kubernetes.io/role/internal-elb", "1",
      "kubernetes.io/role/elb", "1"
    )
  }"
}
resource "aws_subnet" "subnet_az_2" {
  vpc_id            = "${aws_vpc.main_vpc.id}"
  cidr_block        = "${var.SUBNET_AZ2_CIDR}"
  availability_zone = "${var.REGION}b"

  tags = "${
    map(
      "Name", "${var.SUBNET_AZ2_NAME}",
      "kubernetes.io/cluster/${var.cluster-name}", "owned",
      "kubernetes.io/role/internal-elb", "1",
      "kubernetes.io/role/elb", "1"
    )
  }"
}
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.main_vpc.id}"

  tags = {
    Name = "${var.PREFIX}-IGW"
  }
}
resource "aws_route_table" "rt" {
  vpc_id = "${aws_vpc.main_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags = {
    Name = "${var.PREFIX}-Route"
  }
}

resource "aws_route_table_association" "route_table_association_to_subnet_a" {
  subnet_id      = "${aws_subnet.subnet_az_1.id}"
  route_table_id = "${aws_route_table.rt.id}"
}

resource "aws_route_table_association" "route_table_association_to_subnet_b" {
  subnet_id      = "${aws_subnet.subnet_az_2.id}"
  route_table_id = "${aws_route_table.rt.id}"
}
locals {
  eks-cluster-tag = "kubernetes.io/cluster/${aws_eks_cluster.eks_cluster.name}"
}
