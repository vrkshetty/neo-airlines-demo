resource "aws_iam_role" "eksServiceRole" {
  name        = "eksServiceRole"
  description = "Allows Amazon EKS to manage clusters on your behalf."

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "eks.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  }
EOF
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  role       = "${aws_iam_role.eksServiceRole.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}
resource "aws_iam_role_policy_attachment" "AmazonEKSServicePolicy" {
  role       = "${aws_iam_role.eksServiceRole.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}

#to over come this bug https://github.com/coreos/coreos-kubernetes/issues/340
resource "aws_iam_role_policy" "eks_cluster_ingress_loadbalancer_creation" {
  name   = "eks-cluster-ingress-loadbalancer-creation"
  role   = "${aws_iam_role.eksServiceRole.name}"
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeAccountAttributes"
      ],
      "Resource": "*"
    }
  ]
}
POLICY
}
