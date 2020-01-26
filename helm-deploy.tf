resource "null_resource" "helm_deploy" {
  provisioner "local-exec" {
    command = <<EOT
    helm install --namespace tools --name cicd stable/jenkins --values helm-config/jenkins-values.yaml
EOT
  }
  provisioner "local-exec" {
    command = <<EOT
    helm install --namespace tools --name nexus stable/sonatype-nexus --values helm-config/nexus-values.yaml
EOT
  }
  provisioner "local-exec" {
    command = <<EOT
    helm install --namespace tools --name grafana stable/grafana --values helm-config/grafana-values.yaml
EOT
  }


  depends_on = [kubernetes_service_account.tiller]
}
