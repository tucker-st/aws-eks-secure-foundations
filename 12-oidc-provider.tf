# Setup Open ID Connection provider 

data "tls_certificate" "demo" {
  url = aws_eks_cluster.demo.identity[0].oidc[0].issuer

}

resource "aws_iam_openid_connect_provider" "oidc_provider" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.demo.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.demo.identity[0].oidc[0].issuer

  tags = {
    Name = "${var.cluster_name}-eks-irsa"
  }
}

# This is an experiment based on different methods found online.
locals {
  split_from_arn = split("oidc_provider/", aws_iam_openid_connect_provider.oidc_provider.arn)
  extracted      = element(local.split_from_arn, 1)
}