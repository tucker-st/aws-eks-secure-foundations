# We add the prometheus grafana "all-in-one" stack for monitoring the EKS cluster.
# We will use helm to install the stack on the EKS cluster.
# Reference: https://helm.sh/docs/

# We will leverage the prometheus helm chart to install prometheus.

# We set dependency on other services that *must* be up and running
# before we deploy the prometheus stack.

resource "helm_release" "kube-prometheus-stack" {
  depends_on = [aws_eks_node_group.private-nodes,
    null_resource.update_kubeconfig,
  aws_eks_addon.ebs_csi_driver]

  name             = "kube-prometheus-stack"
  namespace        = "monitoring"
  create_namespace = true
  chart            = "kube-prometheus-stack"
  repository       = "https://prometheus-community.github.io/helm-charts"
  version          = "77.1.0"
  values = [
    file("${path.module}/values/kube-prom-values.yaml")
  ]


}