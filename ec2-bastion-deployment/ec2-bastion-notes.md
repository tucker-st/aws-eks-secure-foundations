# EC2 Bastion Instance Notes

In your VPC you may need a bastion with a familiar interface to access and/or manage resources within the VPC. A best practice is to leverage a multi-layered security approach and use a bastion host. In this project there is the option to deploy a Windows Server based bastion host. You can do a similar action leveraging a EC2 Linux instance.

In this project a Windows Server bastion is provided which when its configuraiton is uncommented will deploy a EC2 instance. The instance is accessible using the Remote Desktop Protocol (RDP).

[NOTE] By default the bastion terraform file is commented out to prevent it from being deployed.

[CAUTION] RDP over the internet is not recommended and leveraging a Virtual Private Network or using a EC2 Linux instance would be a much better and more secure option. 

This is only a demonstration resource and it should not be used in production.

# Security Group variable
In the variables.tf file you should set the IP address for variable "client_ip" to the IP address of your remote client system that is running a RDP client.

# Bastion Password

[REFERENCE]

https://repost.aws/knowledge-center/retrieve-windows-admin-password

https://docs.aws.amazon.com/cli/latest/reference/ec2/get-password-data.html#examples

To obtain the password of the bastion EC2 instance you will need to know the password. The default username for a windows EC2 instance is Administrator

In the terraform code the Windows EC2 instance outputs its instance ID. 


1. Get the decrypted password. 
[NOTE] You must have the PEM file that matches the name of the key that was used when the EC2 instance was deployed.
In this project a key named "bastionkey" was used. You will need to change the name of that file to match a key you have
in your AWS region where you deploy the EKS cluster and the EC2 bastion.

In this example command you will need to replace the instance-id value with the value of your actual EC2 instance and also provide the path to the encryption key .pem file.

aws ec2 get-password-data --instance-id  i-1234567890abcdef0 --priv-launch-key C:\Keys\MyKeyPair.pem

# Terminate Windows EC2 Instance
1. If you deployed your EC2 instance via terraform then you can just let terraform terminate your EC2 instance when you perform a terraform destroy. Another method would be to comment out the bastion terraform code and run a terraform plan to verify the EC2 instance will be terminated. Then run terraform apply 

2. You can also access the AWS web console and terminate the EC2 instance.

