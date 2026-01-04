###############################################################################
# variables.tf (no locals)
###############################################################################

variable "enable_kubeconfig" {
  description = "Set to false to skip local kubeconfig update."
  type        = bool
  default     = true
}

variable "region" {
  description = "AWS region (single-region by design)."
  type        = string
  default     = "us-east-1"

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-\\d$", var.region))
    error_message = "region must look like: us-east-1, us-west-2, ap-southeast-1, etc."
  }
}

variable "aws_profile" {
  description = "AWS CLI profile name used by the AWS provider."
  type        = string
  default     = "default"

  validation {
    condition     = can(regex("^[A-Za-z0-9._-]+$", var.aws_profile))
    error_message = "aws_profile must be a simple profile name (letters/numbers/._-)."
  }
}

variable "cluster_name" {
  description = "AWS EKS Cluster Name."
  type        = string
  default     = "staging"
  nullable    = false

  validation {
    condition     = length(var.cluster_name) >= 3 && length(var.cluster_name) <= 40 && can(regex("^[a-zA-Z0-9-]+$", var.cluster_name))
    error_message = "cluster_name must be 3-40 chars and contain only letters, numbers, and hyphens."
  }
}

variable "availability_zones" {
  description = "Optional: Provide 2 AZs. If empty, the first 2 available AZs in the region are used."
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.availability_zones) == 0 || length(var.availability_zones) >= 2
    error_message = "availability_zones must be empty (auto) or contain at least 2 AZs."
  }
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.30.0.0/16"

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "vpc_cidr must be a valid CIDR (e.g., 10.30.0.0/16)."
  }
}

variable "subnet_cidr" {
  description = "CIDR blocks for each private and public subnet."
  type = object({
    private_zone1 = string
    private_zone2 = string
    public_zone1  = string
    public_zone2  = string
  })

  default = {
    private_zone1 = "10.30.0.0/19"
    private_zone2 = "10.30.32.0/19"
    public_zone1  = "10.30.64.0/19"
    public_zone2  = "10.30.96.0/19"
  }

  validation {
    condition = alltrue([
      can(cidrnetmask(var.subnet_cidr.private_zone1)),
      can(cidrnetmask(var.subnet_cidr.private_zone2)),
      can(cidrnetmask(var.subnet_cidr.public_zone1)),
      can(cidrnetmask(var.subnet_cidr.public_zone2)),
    ])
    error_message = "All subnet_cidr values must be valid CIDRs."
  }
}

# Safer-by-default: require a /32 by default so you don't accidentally open admin access broadly.
# If you want to allow wider ranges (or 0.0.0.0/0) for labs, see note below.
variable "client_ip" {
  description = "Remote client IP (CIDR) for security group rules (recommended x.x.x.x/32)."
  type        = string
  default     = "0.0.0.0/0"

  validation {
    condition     = can(cidrnetmask(var.client_ip)) && can(regex("/32$", var.client_ip))
    error_message = "client_ip must be a valid CIDR and end with /32 (example: 203.0.113.10/32)."
  }
}

variable "devops_usernames" {
  description = "List of IAM usernames to create and add to the DevOps group."
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for u in var.devops_usernames : can(regex("^[a-zA-Z0-9+=,.@_-]{1,64}$", u))])
    error_message = "Each devops username must look like a valid IAM username (1-64 chars; letters, numbers, and +=,.@_-)."
  }
}

variable "eks_endpoint_private_access" {
  description = "Enable private endpoint access to the EKS API server."
  type        = bool
  default     = true
}

variable "eks_endpoint_public_access" {
  description = "Enable public endpoint access to the EKS API server (use only with compensating controls)."
  type        = bool
  default     = false
}



variable "eks_pod_identity_version" {
  description = "Version of the AWS EKS Pod Identity Agent to deploy."
  type        = string
  default     = "v1.3.10-eksbuild.2"

  # validation {
  #   condition     = can(regex("^v\\d+\\.\\d+\\.\\d+$", var.eks_pod_identity_version))
  #   error_message = "eks_pod_identity_version must be in the format vX.Y.Z (e.g., v0.13.1)."
  # }
}