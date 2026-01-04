# Environment Setup
1. Set AWS region to the region you intend to manage AWS IAM accounts.

2. Set the storage backend to the region where you will be managing AWS IAM accounts. This S3 bucket will store your terraform "state" files to allow for recovery and management by other users versus maintaining a local state file on a account managers system.


# Create an AWS IAM Group and users


1. Switch to the account_management directory.

- Set your AWS CLI account profile to a user who can perform account administration including creation, deletion and policy management.

2. Revise the file named iam-devops-group.tf

    - Update the usernames in the variable section named “devops_usernames”

    - Set the name of the AWS group in the “name” block of resource “aws_iam_group”

    - If you do not want passwords automatically generated then comment out the section
    labeled “aws_iam_user_login_profile”

    ** If you don’t use the login profile function your IAM administrator will need to
    manually enable console access for each account that is created.

    - Change the name for demo-bucket300 to an actual bucket for your organization.
    
    - Make any required adjustments to the S3 and/or Bedrock IAM policies.

3. Initialize Terraform

```
terraform init
```
```
terraform validate
```

```
terraform plan
```

```
terraform apply
```
After running "terraform apply" you will need to input yes for terraform to run the tasks in your configuration.

4. Verify via AWS CLI or AWS IAM console that the accounts were created and match your required settings.

# Obtaining user password

This is a work in progress since what should occur is encryption of each accounts password and also provide the console sign-in link that AWS IAM creates for each user account that has a password created for the user.

For now you will need to obtain the passwords and manually send notification including the Console sign-in URL to each user who has an account created via terraform.

To obtain the initial password that AWS IAM created you can add this to a file like account_output.tf

The output below will not actually display any account passwords. However uncommenting the field below and running terraform output -json and locating the created user accounts will allow for obtaining unencrypted passwords for each account.

This is a *SERIOUS* subject and best practice would be to use the pgp_key = keybase format and encrypt the passwords.

[REFERENCE] 
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_login_profile

```
#--------WARNING----------------#


# output "password" {
#   value     = aws_iam_user_login_profile.user_login_profile
#   sensitive = true

# }
```



# IAM Account modification (including Account Deletion)
If the account was created leveraging terraform you can delete one or multiple users.

1. Update the usernames with *ONLY* the names you want to modify/delete from IAM.

2. Then run terraform plan to display what terraform plans to do. This is your opportunity to verify what account you are modifying.

3. Run terraform apply and the account will be modified.

# IAM Policy modification

If you need to modify a IAM policy, you can change the JSON file or add an additional policy.

1. Make required revision to the applicable IAM policy.

2. Save the terraform file.

3. Then run terraform plan to display what terraform plans to do. This is your opportunity to verify what account you are modifying.

4. Run terraform apply and the IAM policy should change. You can verify your changes via AWS CLI or via the AWS console for IAM.