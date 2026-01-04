# Setup NAT for cluster nodes.

resource "aws_eip" "nat" {

  tags = {
    Name = "nat"
  }
}

# Set NAT to be in public zone 1.
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "nat-eks-cluster-${var.cluster_name}"
  }

  depends_on = [aws_internet_gateway.igw]
}
