# We add prometheus for monitoring the EKS cluster.
# We will use helm to install prometheus on the EKS cluster.
# Reference: https://helm.sh/docs/

# We will leverage the prometheus helm chart to install prometheus.

# resource "helm_release" "prometheus" {
#   depends_on       = [aws_eks_node_group.private-nodes, null_resource.update_kubeconfig, aws_eks_addon.ebs_csi_driver]
#   name             = "prometheus"
#   namespace        = "monitoring"
#   create_namespace = true
#   chart            = "prometheus"
#   repository       = "https://prometheus-community.github.io/helm-charts"
#   version          = "27.32.0"
#   values = [
#     file("${path.module}/values/prometheus-values.yaml")
#   ]
# }