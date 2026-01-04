#  Internet Gateway for VPC.

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "igw-eks-cluster-${var.cluster_name}"
  }

}