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