# Node setup for EKS cluster.

resource "aws_iam_role" "nodes" {
  name = "${var.cluster_name}-eks-nodes"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "nodes-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.nodes.name
}

# Use Amazon VPC CNI Plugin rather than Flannel or similar
# this is the IAM policy for pods to use native VPC network rather than virtual pod network
resource "aws_iam_role_policy_attachment" "nodes-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.nodes.name
}

# EKS Registry IAM policy
resource "aws_iam_role_policy_attachment" "nodes-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.nodes.name
}

#-----------------#

# EKS managed node group.

resource "aws_eks_node_group" "private-nodes" {
  cluster_name    = aws_eks_cluster.demo.name
  node_group_name = "${var.cluster_name}-private-nodes"

  # Attach IAM role to nodes.

  node_role_arn = aws_iam_role.nodes.arn


  # Set subnets to be in private zones for managed nodes.
  subnet_ids = aws_subnet.private[*].id


  # We leverage standard EC2 instances instead of the default larger types.
  capacity_type  = "ON_DEMAND"
  instance_types = ["t3.large"]

  scaling_config {
    desired_size = 2
    max_size     = 5
    min_size     = 0
  }

  # Identify how many nodes can be down during upgrades of operating system
  # or kubernetes upgrades.
  update_config {
    max_unavailable = 1
  }

  labels = {
    role = "general"
  }

  # Set IAM role policy dependency.
  depends_on = [
    aws_iam_role_policy_attachment.nodes-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.nodes-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.nodes-AmazonEC2ContainerRegistryReadOnly,
  ]
  # Allow external changes without Terraform plan difference.
  # This setting can be somewhat confusing and troublesome. Reference
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster
  # for details.

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

}