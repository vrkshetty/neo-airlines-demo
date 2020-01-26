
data "external" "aws_iam_authenticator" {
  program = ["sh", "-c", "aws eks get-token --cluster-name ${var.cluster-name} --profile ${var.aws_profile} | jq -r -c .status"]
}

provider "kubernetes" {
  host                   = "${aws_eks_cluster.eks_cluster.endpoint}"
  cluster_ca_certificate = "${base64decode(aws_eks_cluster.eks_cluster.certificate_authority.0.data)}"
  token                  = "${data.external.aws_iam_authenticator.result.token}"
  load_config_file       = false
  version                = "~> 1.5"
}


resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }
  data = {
    mapRoles = <<EOF
- rolearn: ${aws_iam_role.node-group-policy.arn}
  username: system:node:{{EC2PrivateDNSName}}
  groups:
    - system:bootstrappers
    - system:nodes
EOF
  }
  depends_on = [aws_eks_cluster.eks_cluster]
}

resource "kubernetes_service_account" "tiller" {
  metadata {
    name      = "tiller"
    namespace = "kube-system"
  }
  depends_on = [aws_eks_cluster.eks_cluster]
}

resource "kubernetes_cluster_role_binding" "tiller" {
  metadata {
    name = "tiller"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "tiller"
    namespace = "kube-system"
    # api_group = "rbac.authorization.k8s.io"
  }
  provisioner "local-exec" {
    command = <<EOT
    aws eks update-kubeconfig --name ${var.cluster-name} --profile ${var.aws_profile} --region ${var.REGION}
EOT
  }
  provisioner "local-exec" {
    command = <<EOT
    helm init --upgrade --wait --service-account tiller
EOT
    provisioner "local-exec" {
      command = <<EOT
  helm install --namespace default --name cicd stable/jenkins --vaules jekins-values.yaml
EOT
    }
    depends_on = [aws_eks_cluster.eks_cluster]

  }
}
