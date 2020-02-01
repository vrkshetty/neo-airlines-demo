resource "null_resource" "helm_deploy" {
  provisioner "local-exec" {
    command = <<EOT
    kubectl apply -f manual-task/deploy-bot-sa.yaml
EOT
  }
  provisioner "local-exec" {
    command = <<EOT
    helm install --namespace tools --name cicd stable/jenkins --values helm-config/jenkins-values.yaml
EOT
  }
  provisioner "local-exec" {
    command = <<EOT
    helm install --namespace tools --name prometheus stable/prometheus --values helm-config/prometheus-vaules.yaml
EOT
  }
  provisioner "local-exec" {
    command = <<EOT
    helm install --namespace tools --name grafana stable/grafana --values helm-config/grafana-values.yaml
EOT
  }


  depends_on = [kubernetes_service_account.tiller]
}
