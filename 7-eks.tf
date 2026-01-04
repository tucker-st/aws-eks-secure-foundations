# Set IAM Role Identity for the cluster.

resource "aws_iam_role" "demo" {
  name = "${var.cluster_name}-eks-cluster-demo"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "eks.amazonaws.com"
      }
    }
  ]
}
POLICY
}

# This is for demo purpose. Need to leverage best practices starting
# from development to production.

resource "aws_iam_role_policy_attachment" "demo-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.demo.name
}

# EKS Cluster service
resource "aws_eks_cluster" "demo" {
  name     = var.cluster_name
  role_arn = aws_iam_role.demo.arn

  # * WARNING *
  # This configuration sets the endpoint access to public!
  # This should be set to private. 
  # Since this is a demonstration cluster which will not be run for any extended period 
  # of time we have it set to public

  # Best practice is to leverage a VPN or other security asset in front of the endpoints.

  vpc_config {
    endpoint_private_access = false
    endpoint_public_access  = true

    subnet_ids = concat(
      [aws_subnet.private[0].id, aws_subnet.private[1].id],
      [aws_subnet.public[0].id, aws_subnet.public[1].id]
    )

  }

  # Cluster access configuration.
  # Access uses API and bootstrap access configurations.

  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = true
  }
  # This setting is critical to ensure EKS mnged resources are 
  # properly managed!
  depends_on = [aws_iam_role_policy_attachment.demo-AmazonEKSClusterPolicy]

}

