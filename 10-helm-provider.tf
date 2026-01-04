data "aws_eks_cluster" "demo" {
  name = aws_eks_cluster.demo.name
}

data "aws_eks_cluster_auth" "demo" {
  name = aws_eks_cluster.demo.name
}


provider "helm" {
  kubernetes = {
    host                   = data.aws_eks_cluster.demo.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.demo.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.demo.token
  }

}