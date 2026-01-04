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

