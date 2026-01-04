###############################################################################
# Terraform Settings & Providers
###############################################################################

# Setup AWS region.
provider "aws" {
  region = var.region

  # *CAUTION* Be sure to set the profile to the AWS account you intend to use. 
  # Otherwise you may be unable to manage the EKS cluster via the AWS console.

  profile = "default"
}

# Terraform providers.

terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.1"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0.5"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0"
    }

  }

  # Storage backend for terraform state files.
  # Be sure that the bucket name you provide here is in the same
  # region as where the kubernetes cluster will reside.

  backend "s3" {
    bucket  = "coldduck203"                        # Set the bucket name to one you own.
    key     = "tshoot-02sept2025-task1-v2.tfstate" # Input your own file name here.
    region  = "us-east-1"                          # Please make sure you make this region match where you deploy your cluster.
    encrypt = true                                 # Enable encryption of your data.
  }

}

# Create an S3 gateway endpoint.
# We can leverage this if we are storing data in S3 buckets besides the terraform
# state file.
/*  resource "aws_vpc_endpoint" "s3_gateway_endpoint" {
  vpc_id = aws_vpc.main.id
  service_name = "com.amazonaws.us-east-1.s3"
  route_table_ids = [aws_route_table.private.id]
  vpc_endpoint_type = "Gateway"
   
 } */



###############################################################################
# Data Sources
###############################################################################


data "aws_availability_zones" "available" {
  state = "available"
}


data "aws_eks_cluster" "demo" {
  name = aws_eks_cluster.demo.name
}

data "aws_eks_cluster_auth" "demo" {
  name = aws_eks_cluster.demo.name
}

data "aws_iam_policy_document" "ebs_csi_driver" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]
  }
}

data "tls_certificate" "demo" {
  url = aws_eks_cluster.demo.identity[0].oidc[0].issuer

}

###############################################################################
# Local Values
###############################################################################

# locals {
#   name_prefix
#   common_tags
#   version pins
# }

###############################################################################
# Networking — VPC & Core Network
###############################################################################

# aws_vpc
resource "aws_vpc" "main" {
  cidr_block = "10.30.0.0/16"

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.cluster_name}-main"
  }


}
# aws_internet_gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "igw-eks-cluster-${var.cluster_name}"
  }

}

# aws_eip (NAT)
resource "aws_eip" "nat" {

  tags = {
    Name = "nat"
  }
}

# aws_nat_gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "nat-eks-cluster-${var.cluster_name}"
  }

  depends_on = [aws_internet_gateway.igw]
}

###############################################################################
# Networking — Subnets
###############################################################################

# aws_subnet (public)

resource "aws_subnet" "public" {
  count = 2

  vpc_id                  = aws_vpc.main.id
  cidr_block              = element([var.subnet_cidr.public_zone1, var.subnet_cidr.public_zone2], count.index)
  availability_zone       = length(var.availability_zones) >= 2 ? var.availability_zones[count.index] : data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "public-${length(var.availability_zones) >= 2 ? var.availability_zones[count.index] : data.aws_availability_zones.available.names[count.index]}"
  }
}

# aws_subnet (private)




resource "aws_subnet" "private" {
  count = 2

  vpc_id                  = aws_vpc.main.id
  cidr_block              = element([var.subnet_cidr.private_zone1, var.subnet_cidr.private_zone2], count.index)
  availability_zone       = length(var.availability_zones) >= 2 ? var.availability_zones[count.index] : data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "private-${length(var.availability_zones) >= 2 ? var.availability_zones[count.index] : data.aws_availability_zones.available.names[count.index]}"
  }
}




###############################################################################
# Networking — Routing
###############################################################################

# aws_route_table (public)
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public"
  }
}

# aws_route_table (private)
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "private"
  }
}
# aws_route_table_association

resource "aws_route_table_association" "public_zone1" {
  subnet_id      = aws_subnet.public[0].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_zone2" {
  subnet_id      = aws_subnet.public[1].id
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "private_zone1" {
  subnet_id      = aws_subnet.private[0].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_zone2" {
  subnet_id      = aws_subnet.private[1].id
  route_table_id = aws_route_table.private.id
}


###############################################################################
# Security Groups
###############################################################################

# aws_security_group (bastion, control plane access, etc.)
# Static Security groups for EKS Cluster and VPC
# The EKS cluster will create security groups as services 
# are created and delete them when the service is destroyed.

# We will use this security group to provide a layer of protection
# for assets at the VPC level.

resource "aws_security_group" "vpc-sg01-bastion" {
  name        = "${var.cluster_name}-sg01-bastion"
  description = "Allow RDP inbound traffic to bastion host"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "BastionRDP"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    # This value should be set to your remote management client.
    # It is preferable to leverage a VPN tunnel between the VPC and your client information system
    # instead of passing RDP traffic over a public network.
    cidr_blocks = ["${var.client_ip}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name                            = "${var.cluster_name}-sg01-bastion"
    Service                         = "BastionHost"
    "kubernetes.io/cluster/staging" = "owned"
  }
}

###############################################################################
# IAM — Cluster & Node Roles
###############################################################################

# aws_iam_role (EKS cluster)
# aws_iam_role (node group)
# aws_iam_policy
# aws_iam_role_policy_attachment

###############################################################################
# Amazon EKS — Control Plane
###############################################################################

# aws_eks_cluster
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

###############################################################################
# Amazon EKS — Node Groups
###############################################################################

# aws_eks_node_group
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

###############################################################################
# IAM OIDC & Pod Identity (IRSA)
###############################################################################

# aws_iam_openid_connect_provider


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

# aws_eks_pod_identity_association
resource "aws_eks_addon" "pod_identity" {
  cluster_name  = aws_eks_cluster.demo.name
  addon_name    = "eks-pod-identity-agent"
  addon_version = "v1.3.8-eksbuild.2"
}

###############################################################################
# EKS Managed Add-ons
###############################################################################

# aws_eks_addon (EBS CSI)


resource "aws_iam_role" "ebs_csi_driver" {
  name               = "${aws_eks_cluster.demo.name}-ebs-csi-driver"
  assume_role_policy = data.aws_iam_policy_document.ebs_csi_driver.json
}

resource "aws_iam_role_policy_attachment" "ebs_csi_driver" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.ebs_csi_driver.name
}

# Optional: only if you want to encrypt the EBS drives
resource "aws_iam_policy" "ebs_csi_driver_encryption" {
  name = "${aws_eks_cluster.demo.name}-ebs-csi-driver-encryption"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKeyWithoutPlaintext",
          "kms:CreateGrant"
        ]
        Resource = "*"
      }
    ]
  })
}

# Optional: only if you want to encrypt the EBS drives
resource "aws_iam_role_policy_attachment" "ebs_csi_driver_encryption" {
  policy_arn = aws_iam_policy.ebs_csi_driver_encryption.arn
  role       = aws_iam_role.ebs_csi_driver.name
}

resource "aws_eks_pod_identity_association" "ebs_csi_driver" {
  cluster_name    = aws_eks_cluster.demo.name
  namespace       = "kube-system"
  service_account = "ebs-csi-controller-sa"
  role_arn        = aws_iam_role.ebs_csi_driver.arn
}

resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name             = aws_eks_cluster.demo.name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = "v1.48.0-eksbuild.1"
  service_account_role_arn = aws_iam_role.ebs_csi_driver.arn

  # Added this since the EBS addon was attempting to be added
  # while the nodes were being deployed.
  # Error message " InsufficientNumberOfReplicas The add-on is unhealthy because all deployments 
  # have all pods unscheduled no nodes available to schedule pods "
  # Need to resolve this issue for this addon.

  depends_on = [aws_eks_node_group.private-nodes,
    aws_eks_cluster.demo,
    aws_iam_openid_connect_provider.oidc_provider,
    null_resource.update_kubeconfig
  ]
}

# aws_eks_addon (pod identity agent, if applicable)

###############################################################################
# Helm Provider Configuration
###############################################################################

# provider "helm" (cluster auth wiring)



provider "helm" {
  kubernetes = {
    host                   = data.aws_eks_cluster.demo.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.demo.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.demo.token
  }

}

###############################################################################
# Kubernetes Platform Add-ons (Helm)
###############################################################################

# helm_release (metrics-server)


resource "helm_release" "metrics_server" {
  name = "metrics-server"

  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  namespace  = "kube-system"
  version    = "3.12.1"

  values = [file("${path.module}/values/metrics-server.yaml")]

  depends_on = [aws_eks_node_group.private-nodes]
}

# helm_release (cluster-autoscaler)
resource "aws_iam_role" "cluster_autoscaler" {
  name = "${aws_eks_cluster.demo.name}-cluster-autoscaler"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "cluster_autoscaler" {
  name = "${aws_eks_cluster.demo.name}-cluster-autoscaler"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeScalingActivities",
          "autoscaling:DescribeTags",
          "ec2:DescribeImages",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeLaunchTemplateVersions",
          "ec2:GetInstanceTypesFromInstanceRequirements",
          "eks:DescribeNodegroup"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup"
        ]
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_autoscaler" {
  policy_arn = aws_iam_policy.cluster_autoscaler.arn
  role       = aws_iam_role.cluster_autoscaler.name
}

resource "aws_eks_pod_identity_association" "cluster_autoscaler" {
  cluster_name    = aws_eks_cluster.demo.name
  namespace       = "kube-system"
  service_account = "cluster-autoscaler"
  role_arn        = aws_iam_role.cluster_autoscaler.arn
}

resource "helm_release" "cluster_autoscaler" {
  name = "autoscaler"

  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  namespace  = "kube-system"
  version    = "9.37.0"



  set = [{
    name  = "rbac.serviceAccount.name"
    value = "cluster-autoscaler"
    },
    {
      name  = "autoDiscovery.clusterName"
      value = aws_eks_cluster.demo.name
    },

    # MUST be updated to match your region 
    {
      name  = "awsRegion"
      value = "${var.region}"

      depends_on = [helm_release.metrics_server]
    }
  ]

}

# helm_release (aws-load-balancer-controller)

# data "aws_iam_policy_document" "aws_lbc" {
#   statement {
#     effect = "Allow"

#     principals {
#       type        = "Service"
#       identifiers = ["pods.eks.amazonaws.com"]
#     }

#     actions = [
#       "sts:AssumeRole",
#       "sts:TagSession"
#     ]
#   }
# }

# resource "aws_iam_role" "aws_lbc" {
#   name               = "${aws_eks_cluster.demo.name}-aws-lbc"
#   assume_role_policy = data.aws_iam_policy_document.aws_lbc.json
# }

# resource "aws_iam_policy" "aws_lbc" {
#   policy = file("./iam/AWSLoadBalancerController.json")
#   name   = "AWSLoadBalancerController"
# }

# resource "aws_iam_role_policy_attachment" "aws_lbc" {
#   policy_arn = aws_iam_policy.aws_lbc.arn
#   role       = aws_iam_role.aws_lbc.name
# }

# resource "aws_eks_pod_identity_association" "aws_lbc" {
#   cluster_name    = aws_eks_cluster.demo.name
#   namespace       = "kube-system"
#   service_account = "aws-load-balancer-controller"
#   role_arn        = aws_iam_role.aws_lbc.arn
# }

# resource "helm_release" "aws_lbc" {
#   name = "aws-load-balancer-controller"

#   repository = "https://aws.github.io/eks-charts"
#   chart      = "aws-load-balancer-controller"
#   namespace  = "kube-system"
#   version    = "1.7.2"

#   set = [{
#     name  = "clusterName"
#     value = aws_eks_cluster.demo.name
#     },

#     {
#       name  = "serviceAccount.name"
#       value = "aws-load-balancer-controller"
#     },
#     {
#       name  = "vpcId"
#       value = aws_vpc.main.id

#       depends_on = [helm_release.cluster_autoscaler]
#     }
#   ]

# }

###############################################################################
# Observability Stack
###############################################################################

# helm_release (prometheus)

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

# helm_release (grafana)

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

## helm_release (kube-prometheus-stack)
## Here you have the option to either use Grafana and Prometheus separately
## as above, or use the all-in-one stack below.

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


###############################################################################
# Platform Services
###############################################################################

# helm_release (portainer)

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

# ECR repositories

# resource "aws_ecrpublic_repository" "public_repo" {
#   repository_name = "my-public-app"
# }

# resource "aws_ecrpublic_repository_policy" "public_policy" {
#   repository_name = aws_ecrpublic_repository.public_repo.repository_name

#   policy = jsonencode({
#     Version = "2008-10-17"
#     Statement = [
#       {
#         Sid       = "AllowPull"
#         Effect    = "Allow"
#         Principal = "*"
#         Action    = [
#           "ecr-public:GetRepositoryCatalogData",
#           "ecr-public:GetRepositoryPolicy",
#           "ecr-public:DescribeImageTags",
#           "ecr-public:DescribeImages",
#           "ecr-public:BatchCheckLayerAvailability",
#           "ecr-public:GetDownloadUrlForLayer",
#           "ecr-public:BatchGetImage"
#         ]
#       }
#     ]
#   })
# }


# container images (if any)
# Here is where we store the names of our docker containerized images.

# Identify the name of the Docker Image in ECR. We must use the tag name of the image.

# resource "aws_ecr_repository" "my_app_repo" {
#   name = "my-app-repo"
# }

# resource "aws_ecr_lifecycle_policy" "my_app_repo_policy" {
#   repository = aws_ecr_repository.my_app_repo.name}
#   policy     = file("${path.module}/iam/ecr-lifecycle-policy.json")
# }

###############################################################################
# Bastion / Administrative Access (Optional)
###############################################################################

# aws_instance (bastion)
# Here we deploy a bastion EC2 instance running Windows Server. 

# Uncomment this section if you want to deploy a bastion client in
# the EKS VPC cluster.

/* resource "aws_network_interface" "bastion_ext" {
  subnet_id = aws_subnet.public[0].id

  tags = {
    Name = "primary_network_interface"
  }
}


# Create Windows EC2 Instance
resource "aws_instance" "bastion-evilbox" {
  ami                         = "ami-0efee5160a1079475"
  instance_type               = "t3.medium"
  subnet_id                   = aws_subnet.public[0].id
  vpc_security_group_ids      = [aws_security_group.vpc-sg01-bastion.id]
  associate_public_ip_address = true

  # Insert the name of your own keys that you have uploaded to AWS in the region where the 
  # VPC is located.
  key_name          = "bastionkeys"
  get_password_data = true


  depends_on = [aws_vpc.main, aws_subnet.public[0], aws_internet_gateway.igw]



  tags = {
    Name = "bastion-evilbox"
  }
}

output "bastion_ip" {
  description = "Provide public IP address of bastion EC2 instance. "
  value       = ["${aws_instance.bastion-evilbox.public_ip}"]
}

output "Adminstrator_Password" {
  value = [
    aws_instance.bastion-evilbox.password_data
  ]

}

output "bastion_instance_id" {
  description = "Provide instance ID of bastion EC2 instance."
  value = [
    aws_instance.bastion-evilbox.id
  ]

} */

# related IAM / security group rules

###############################################################################
# Local Runtime Helpers
###############################################################################

# null_resource (kubeconfig update, local exec hooks)

# Connect to cluster (add proper context to kubeconfig)

resource "null_resource" "update_kubeconfig" {
  count = var.enable_kubeconfig ? 1 : 0

  provisioner "local-exec" {
    #interpreter=["bash", "-c"]
    command = "aws eks update-kubeconfig --region ${var.region} --name ${aws_eks_cluster.demo.name}"
  }

  depends_on = [aws_eks_cluster.demo]
}

###############################################################################
# Outputs
###############################################################################

# (If you keep outputs in main.tf; otherwise move to outputs.tf)

# Provide outputs to the console where terraform is being run from.

output "eks_cluster_info" {
  value = {
    name        = aws_eks_cluster.demo.name
    endpoint    = aws_eks_cluster.demo.endpoint
    arn         = aws_eks_cluster.demo.arn
    id          = aws_eks_cluster.demo.id
    description = "EKS cluster details"
  }
}

output "eks_node_group_summary" {
  value = format("Node group '%s' runs %s instance(s) of type %s",
    aws_eks_node_group.private-nodes.node_group_name,
    aws_eks_node_group.private-nodes.scaling_config[0].desired_size,
    join(", ", aws_eks_node_group.private-nodes.instance_types)
  )
  description = "Summary of EKS node group configuration"
}

# Output: AWS IAM Open ID Connect Provider ARN
output "openid_connect_provider" {
  description = "AWS IAM Open ID Connect Provider ARN"
  value = {
    arn = aws_iam_openid_connect_provider.oidc_provider.arn
    url = aws_eks_cluster.demo.identity[0].oidc[0].issuer
  }
}
