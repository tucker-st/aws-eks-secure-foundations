# This create a vpc.id where the EKS cluster will reside.

resource "aws_vpc" "main" {
  cidr_block = "10.30.0.0/16"

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.cluster_name}-main"
  }


}
