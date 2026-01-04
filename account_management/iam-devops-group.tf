# Setup AWS region.
provider "aws" {
  region = "us-east-1"
}

# Terraform providers.

terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.11.0"
    }
  }

  # Storage backend for terraform state files.
  # Be sure that the bucket name you provide here is in the same
  # region as where the kubernetes cluster will reside.

  backend "s3" {
    bucket  = "coldduck203"                        # Set the bucket name to one you own.
    key     = "02sept2025-acct-management.tfstate" # Input your own file name here.
    region  = "us-east-1"                          # Please make sure you make this region match where you deploy your cluster.
    encrypt = true                                 # Enable encryption of your data.
  }

}


# Create AWS IAM group and add users to the group.


# This variable file provides the accounts that can be created by an
# authorized administrator.

# List of usernames
# You should replace these test accounts with actual user accounts.

variable "devops_usernames" {
  type        = list(string)
  default     = ["JangoFett", "CountDooku", "GeneralGrievous", "Emperor", "MrMajestik"]
  description = "List of usernames to be allowed access to AWS"
}


# Create an AWS IAM group

resource "aws_iam_group" "devops_group" {
  name = "class06_aws_devops_group"

}

# Resource to create an AWS IAM user.

resource "aws_iam_user" "userlist" {
  count         = length(var.devops_usernames)
  name          = element(var.devops_usernames, count.index)
  force_destroy = true

}

# Creates a login profile. This needs to be revised as the passwords are not output
resource "aws_iam_user_login_profile" "user_login_profile" {
  count                   = length(var.devops_usernames)
  user                    = element(var.devops_usernames, count.index)
  password_length         = 40
  password_reset_required = true
  depends_on              = [aws_iam_user.userlist]

}



# Associate AWS IAM users to group.

resource "aws_iam_user_group_membership" "user_group_membership" {
  count  = length(var.devops_usernames)
  user   = element(var.devops_usernames, count.index)
  groups = [aws_iam_group.devops_group.name, ]


}

# Create passwords


# Setup IAM policy for Read Only access to a specific S3 bucket.

resource "aws_iam_policy" "dev_group_s3_policy" {
  name        = "devgroup-s3-policy"
  description = "Policy for Read Only access to a S3 bucket"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "LocateBucket",
        "Effect" : "Allow",
        "Action" : "s3:GetBucketLocation",
        "Resource" : "arn:aws:s3:::demo-bucket300"
      },
      {
        "Sid" : "ListObjectsInBucket",
        "Effect" : "Allow",
        "Action" : "s3:ListBucket",
        "Resource" : "arn:aws:s3:::demo-bucket300"
      },
    ]
  })
}

resource "aws_iam_group_policy_attachment" "dev_group_s3_policy" {
  group      = aws_iam_group.devops_group.name
  policy_arn = aws_iam_policy.dev_group_s3_policy.arn

}

# Setup IAM policy for Bedrock Admin access.

resource "aws_iam_policy" "dev_group_bedrock_limited_policy" {
  name        = "devgroup-bedrock-limited-policy"
  description = "Policy for access to Amazon bedrock"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "BedrockAPIs",
        "Effect" : "Allow",
        "Action" : [
          "bedrock:Get*",
          "bedrock:List*",
          "bedrock:CallWithBearerToken",
          "bedrock:BatchDeleteEvaluationJob",
          "bedrock:CreateEvaluationJob",
          "bedrock:CreateGuardrail",
          "bedrock:CreateGuardrailVersion",
          "bedrock:CreateInferenceProfile",
          "bedrock:CreateModelCopyJob",
          "bedrock:CreateModelCustomizationJob",
          "bedrock:CreateModelImportJob",
          "bedrock:CreateModelInvocationJob",
          "bedrock:CreatePromptRouter",
          "bedrock:CreateProvisionedModelThroughput",
          "bedrock:DeleteCustomModel",
          "bedrock:DeleteGuardrail",
          "bedrock:DeleteImportedModel",
          "bedrock:DeleteInferenceProfile",
          "bedrock:DeletePromptRouter",
          "bedrock:DeleteProvisionedModelThroughput",
          "bedrock:StopEvaluationJob",
          "bedrock:StopModelCustomizationJob",
          "bedrock:StopModelInvocationJob",
          "bedrock:TagResource",
          "bedrock:UntagResource",
          "bedrock:UpdateGuardrail",
          "bedrock:UpdateProvisionedModelThroughput",
          "bedrock:ApplyGuardrail",
          "bedrock:InvokeModel",
          "bedrock:InvokeModelWithResponseStream"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "DescribeKey",
        "Effect" : "Allow",
        "Action" : [
          "kms:DescribeKey"
        ],
        "Resource" : "arn:*:kms:*:::*"
      },
      {
        "Sid" : "APIsWithAllResourceAccess",
        "Effect" : "Allow",
        "Action" : [
          "iam:ListRoles",
          "ec2:DescribeVpcs",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "MarketplaceOperationsFromBedrockFor3pModels",
        "Effect" : "Allow",
        "Action" : [
          "aws-marketplace:Subscribe",
          "aws-marketplace:ViewSubscriptions",
          "aws-marketplace:Unsubscribe"
        ],
        "Resource" : "*",
        "Condition" : {
          "StringEquals" : {
            "aws:CalledViaLast" : "bedrock.amazonaws.com"
          }
        }
      }
    ]
  })
}

# Attach Bedrock policy to devops group

resource "aws_iam_group_policy_attachment" "dev_group_bedrock_limited_policy" {
  group      = aws_iam_group.devops_group.name
  policy_arn = aws_iam_policy.dev_group_bedrock_limited_policy.arn

}


#------------Amazon Bedrock Marketplace Access-------------#

resource "aws_iam_policy" "dev_group_bedrock_marketplace_policy" {
  name        = "devgroup-bedrock-marketplace-policy"
  description = "Policy for access to Amazon Bedrock Marketplace"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "BedrockMarketplaceAPIs",
        "Effect" : "Allow",
        "Action" : [
          "bedrock:CreateMarketplaceModelEndpoint",
          "bedrock:DeleteMarketplaceModelEndpoint",
          "bedrock:DeregisterMarketplaceModelEndpoint",
          "bedrock:RegisterMarketplaceModelEndpoint",
          "bedrock:UpdateMarketplaceModelEndpoint"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "MarketplaceModelEndpointMutatingAPIs",
        "Effect" : "Allow",
        "Action" : [
          "sagemaker:CreateEndpoint",
          "sagemaker:CreateEndpointConfig",
          "sagemaker:CreateModel",
          "sagemaker:DeleteEndpoint",
          "sagemaker:UpdateEndpoint"
        ],
        "Resource" : [
          "arn:aws:sagemaker:*:*:endpoint/*",
          "arn:aws:sagemaker:*:*:endpoint-config/*",
          "arn:aws:sagemaker:*:*:model/*"
        ],
        "Condition" : {
          "StringEquals" : {
            "aws:CalledViaLast" : "bedrock.amazonaws.com",
            "aws:ResourceTag/sagemaker-sdk:bedrock" : "compatible"
          }
        }
      },
      {
        "Sid" : "MarketplaceModelEndpointAddTagsOperations",
        "Effect" : "Allow",
        "Action" : [
          "sagemaker:AddTags"
        ],
        "Resource" : [
          "arn:aws:sagemaker:*:*:endpoint/*",
          "arn:aws:sagemaker:*:*:endpoint-config/*",
          "arn:aws:sagemaker:*:*:model/*"
        ],
        "Condition" : {
          "ForAllValues:StringEquals" : {
            "aws:TagKeys" : [
              "sagemaker-sdk:bedrock",
              "bedrock:marketplace-registration-status",
              "sagemaker-studio:hub-content-arn"
            ]
          },
          "StringLike" : {
            "aws:RequestTag/sagemaker-sdk:bedrock" : "compatible",
            "aws:RequestTag/bedrock:marketplace-registration-status" : "registered",
            "aws:RequestTag/sagemaker-studio:hub-content-arn" : "arn:aws:sagemaker:*:aws:hub-content/SageMakerPublicHub/Model/*"
          }
        }
      },
      {
        "Sid" : "MarketplaceModelEndpointDeleteTagsOperations",
        "Effect" : "Allow",
        "Action" : [
          "sagemaker:DeleteTags"
        ],
        "Resource" : [
          "arn:aws:sagemaker:*:*:endpoint/*",
          "arn:aws:sagemaker:*:*:endpoint-config/*",
          "arn:aws:sagemaker:*:*:model/*"
        ],
        "Condition" : {
          "ForAllValues:StringEquals" : {
            "aws:TagKeys" : [
              "sagemaker-sdk:bedrock",
              "bedrock:marketplace-registration-status",
              "sagemaker-studio:hub-content-arn"
            ]
          },
          "StringLike" : {
            "aws:ResourceTag/sagemaker-sdk:bedrock" : "compatible",
            "aws:ResourceTag/bedrock:marketplace-registration-status" : "registered",
            "aws:ResourceTag/sagemaker-studio:hub-content-arn" : "arn:aws:sagemaker:*:aws:hub-content/SageMakerPublicHub/Model/*"
          }
        }
      },
      {
        "Sid" : "MarketplaceModelEndpointNonMutatingAPIs",
        "Effect" : "Allow",
        "Action" : [
          "sagemaker:DescribeEndpoint",
          "sagemaker:DescribeEndpointConfig",
          "sagemaker:DescribeModel",
          "sagemaker:DescribeInferenceComponent",
          "sagemaker:ListEndpoints",
          "sagemaker:ListTags"
        ],
        "Resource" : [
          "arn:aws:sagemaker:*:*:endpoint/*",
          "arn:aws:sagemaker:*:*:endpoint-config/*",
          "arn:aws:sagemaker:*:*:model/*"
        ],
        "Condition" : {
          "StringEquals" : {
            "aws:CalledViaLast" : "bedrock.amazonaws.com"
          }
        }
      },
      {
        "Sid" : "MarketplaceModelEndpointInvokingOperations",
        "Effect" : "Allow",
        "Action" : [
          "sagemaker:InvokeEndpoint",
          "sagemaker:InvokeEndpointWithResponseStream"
        ],
        "Resource" : [
          "arn:aws:sagemaker:*:*:endpoint/*"
        ],
        "Condition" : {
          "StringEquals" : {
            "aws:CalledViaLast" : "bedrock.amazonaws.com",
            "aws:ResourceTag/sagemaker-sdk:bedrock" : "compatible"
          }
        }
      },
      {
        "Sid" : "DiscoveringMarketplaceModel",
        "Effect" : "Allow",
        "Action" : [
          "sagemaker:DescribeHubContent"
        ],
        "Resource" : [
          "arn:aws:sagemaker:*:aws:hub-content/SageMakerPublicHub/Model/*",
          "arn:aws:sagemaker:*:aws:hub/SageMakerPublicHub"
        ]
      },
      {
        "Sid" : "AllowMarketplaceModelsListing",
        "Effect" : "Allow",
        "Action" : [
          "sagemaker:ListHubContents"
        ],
        "Resource" : "arn:aws:sagemaker:*:aws:hub/SageMakerPublicHub"
      },
      {
        "Sid" : "PassRoleToSageMaker",
        "Effect" : "Allow",
        "Action" : [
          "iam:PassRole"
        ],
        "Resource" : [
          "arn:aws:iam::*:role/*SageMaker*ForBedrock*"
        ],
        "Condition" : {
          "StringEquals" : {
            "iam:PassedToService" : [
              "sagemaker.amazonaws.com",
              "bedrock.amazonaws.com"
            ]
          }
        }
      },
      {
        "Sid" : "PassRoleToBedrock",
        "Effect" : "Allow",
        "Action" : [
          "iam:PassRole"
        ],
        "Resource" : "arn:aws:iam::*:role/*AmazonBedrock*",
        "Condition" : {
          "StringEquals" : {
            "iam:PassedToService" : [
              "bedrock.amazonaws.com"
            ]
          }
        }
      }
    ]
  })
}

# Attach Bedrock Marketplace policy to devops group

resource "aws_iam_group_policy_attachment" "dev_group_bedrock_marketplace_policy" {
  group      = aws_iam_group.devops_group.name
  policy_arn = aws_iam_policy.dev_group_bedrock_marketplace_policy.arn

}