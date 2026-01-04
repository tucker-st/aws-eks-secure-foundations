# We add the portainer to the EKS cluster.
# We will use helm to install the portainer on the EKS cluster.
# Reference: https://helm.sh/docs/

# We will leverage the portainer chart with a customized values.yaml helm chart.

# We set dependency on other services that *must* be up and running
# before we deploy the portainer stack.

resource "helm_release" "portainer" {
  depends_on = [aws_eks_node_group.private-nodes,
    null_resource.update_kubeconfig,
  aws_eks_addon.ebs_csi_driver]

  name             = "portainer"
  namespace        = "portainer"
  create_namespace = true
  chart            = "portainer"
  repository       = "https://portainer.github.io/k8s/"
  #version          = "77.1.0"
  values = [
    file("${path.module}/values/portainer-values.yaml")
  ]


}