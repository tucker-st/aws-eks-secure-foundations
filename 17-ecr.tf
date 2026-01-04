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
