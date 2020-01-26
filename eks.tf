resource "aws_eks_cluster" "eks_cluster" {
  name     = "${var.cluster-name}"
  role_arn = "${aws_iam_role.eksServiceRole.arn}"

  vpc_config {
    security_group_ids = ["${aws_security_group.eks-cluster.id}"]
    subnet_ids         = ["${aws_subnet.subnet_az_1.id}", "${aws_subnet.subnet_az_2.id}"]
  }

  provisioner "local-exec" {
    command = <<EOT
  aws eks update-kubeconfig --name ${var.cluster-name} --profile ${var.aws_profile} --region ${var.REGION}
EOT
  }
}
resource "aws_iam_role_policy_attachment" "eks-cluster-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = "${aws_iam_role.eksServiceRole.name}"
}

resource "aws_security_group" "eks-cluster" {
  name        = "terraform-eks-eks-cluster"
  description = "Cluster communication with worker nodes"
  vpc_id      = "${aws_vpc.main_vpc.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform-eks"
  }
}

resource "aws_security_group_rule" "eks-cluster-ingress-node-https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.eks-cluster.id}"
  source_security_group_id = "${aws_security_group.wrk-grp-1.id}"
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group_rule" "eks-cluster-ingress-workstation-https" {
  cidr_blocks       = ["${var.VPC_CIDR}"]
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = "${aws_security_group.eks-cluster.id}"
  to_port           = 443
  type              = "ingress"
}
output "endpoint" {
  value = "${aws_eks_cluster.eks_cluster.endpoint}"
}

output "kubeconfig-certificate-authority-data" {
  value = "${aws_eks_cluster.eks_cluster.certificate_authority.0.data}"
}
