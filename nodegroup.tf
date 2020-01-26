resource "aws_iam_role" "node-group-policy" {
  name = "terraform-eks-node-group-policy"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "wrk-grp-1-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = "${aws_iam_role.node-group-policy.name}"
}

resource "aws_iam_role_policy_attachment" "wrk-grp-1-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = "${aws_iam_role.node-group-policy.name}"
}

resource "aws_iam_role_policy_attachment" "wrk-grp-1-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = "${aws_iam_role.node-group-policy.name}"
}

resource "aws_iam_instance_profile" "wrk-grp-1" {
  name = "terraform-eks-demo"
  role = "${aws_iam_role.node-group-policy.name}"
}

resource "aws_security_group" "wrk-grp-1" {
  name        = "terraform-eks-wrk-grp-1"
  description = "Security group for all nodes in the cluster"
  vpc_id      = "${aws_vpc.main_vpc.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${
    map(
      "Name", "terraform-eks-wrk-grp-1",
      "kubernetes.io/cluster/${aws_eks_cluster.eks_cluster.name}", "owned",
    )
  }"
}

resource "aws_security_group_rule" "wrk-grp-1-ingress-self" {
  description              = "Allow node to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = "${aws_security_group.wrk-grp-1.id}"
  source_security_group_id = "${aws_security_group.wrk-grp-1.id}"
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "wrk-grp-1-ingress-cluster" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.wrk-grp-1.id}"
  source_security_group_id = "${aws_security_group.eks-cluster.id}"
  to_port                  = 65535
  type                     = "ingress"
}
resource "aws_security_group_rule" "ControlPlaneEgressToNodeSecurityGroupOn443" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.wrk-grp-1.id}"
  source_security_group_id = "${aws_security_group.eks-cluster.id}"
  to_port                  = 443
  type                     = "ingress"
}



data "aws_ami" "eks-worker" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-${aws_eks_cluster.eks_cluster.version}-v*"]
  }

  most_recent = true
  owners      = ["602401143452"] # Amazon EKS AMI Account ID
}


locals {
  wrk-grp-1-userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.eks_cluster.endpoint}' --b64-cluster-ca '${aws_eks_cluster.eks_cluster.certificate_authority.0.data}' '${aws_eks_cluster.eks_cluster.name}'
USERDATA
}

resource "aws_launch_configuration" "eks_as_launch" {
  associate_public_ip_address = true
  iam_instance_profile        = "${aws_iam_instance_profile.wrk-grp-1.name}"
  image_id                    = "${data.aws_ami.eks-worker.id}"
  instance_type               = "t2.large"
  name_prefix                 = "terraform-eks-wrk-grp-1"
  security_groups             = ["${aws_security_group.wrk-grp-1.id}"]
  user_data_base64            = "${base64encode(local.wrk-grp-1-userdata)}"
  key_name                    = "${var.ssh_key_name}"
  depends_on                  = [kubernetes_config_map.aws_auth]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "eks_as_launch" {
  desired_capacity     = 2
  launch_configuration = "${aws_launch_configuration.eks_as_launch.id}"
  max_size             = 2
  min_size             = 2
  name                 = "terraform-eks-wrk-as"
  vpc_zone_identifier  = ["${aws_subnet.subnet_az_1.id}", "${aws_subnet.subnet_az_2.id}"]

  tag {
    key                 = "Name"
    value               = "NEO-EKS-DEMO"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${aws_eks_cluster.eks_cluster.name}"
    value               = "owned"
    propagate_at_launch = true
  }
}
# 
