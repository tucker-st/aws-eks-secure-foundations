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