# We add grafana for graphical display of data produced by prometheus and other sources in the EKS cluster.
# We will use helm to install grafana on the EKS cluster.
# Reference: https://helm.sh/docs/

# We will leverage the grafana helm chart to perform the installation..

# resource "helm_release" "grafana" {
#   depends_on = [aws_eks_node_group.private-nodes, null_resource.update_kubeconfig,
#   aws_eks_addon.ebs_csi_driver, helm_release.prometheus]
#   name             = "grafana"
#   namespace        = "monitoring"
#   create_namespace = true
#   chart            = "grafana"
#   repository       = "https://grafana.github.io/helm-charts"
#   version          = "9.4.0"

#   values = [file("${path.module}/values/grafana-values.yaml")]
# }