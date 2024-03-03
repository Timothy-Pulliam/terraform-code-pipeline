# About

A Terraform script that creates an AWS CodePipeline capable of building docker images and pushing to a created ECR repository. CodePipeline execution is triggered by a CloudWatch event that detects when changes to the main branch of a created CodeCommit repository are detected. The `buildspec.yml` defines the CodeBuild build process (build docker image, push to ECR).

- ECR Repository
- CodeCommit Repository
- CodeBuild Project
- CodePipeline project
- S3 artifact store
- Necessary roles for CodeBuild and CodePipeline
- CloudWatch log group for build logs

![](/pipeline.png)

# Prerequisites

## Code Commit Authentication

You will need to upload an SSH key to AWS IAM in order to authenticate to the Code Commit repository

```
# generate RSA key
ssh-keygen -t rsa -b 4096 -f ~/.ssh/codecommit_rsa
# upload to AWS IAM
aws iam upload-ssh-public-key --user-name USER-NAME --ssh-public-key-body "$(cat ~/.ssh/codecommit_rsa.pub)"
```

Optionally, you can configure your client to use this key by adding the following to your `~/.ssh/config`

```
Host git-codecommit.*.amazonaws.com
  User USER-NAME
  IdentityFile ~/.ssh/codecommit_rsa
```

## buildspec.yml

The included `buildspec.yml` instructs CodeBuild to build a docker image and push to the created ECR repository. You should include it in the top level directory of your project. For example `~/my-project/buildspec.yml`

## Requirements

| Name                                                                     | Version  |
| ------------------------------------------------------------------------ | -------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.7.4 |
| <a name="requirement_aws"></a> [aws](#requirement_aws)                   | ~> 5.0   |

## Providers

| Name                                             | Version |
| ------------------------------------------------ | ------- |
| <a name="provider_aws"></a> [aws](#provider_aws) | 5.38.0  |

## Modules

No modules.

## Resources

| Name                                                                                                                                                                  | Type        |
| --------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [aws_cloudwatch_event_rule.codecommit_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule)                        | resource    |
| [aws_cloudwatch_event_target.codepipeline_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target)                | resource    |
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group)                                     | resource    |
| [aws_codebuild_project.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_project)                                           | resource    |
| [aws_codecommit_repository.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codecommit_repository)                                   | resource    |
| [aws_codepipeline.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codepipeline)                                                     | resource    |
| [aws_ecr_repository.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository)                                                 | resource    |
| [aws_iam_policy.cloudwatch_event_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy)                                      | resource    |
| [aws_iam_policy.codebuild_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy)                                             | resource    |
| [aws_iam_policy.codepipeline_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy)                                          | resource    |
| [aws_iam_role.cloudwatch_event_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)                                            | resource    |
| [aws_iam_role.codebuild_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)                                                   | resource    |
| [aws_iam_role.codepipeline_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)                                                | resource    |
| [aws_iam_role_policy_attachment.cloudwatch_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource    |
| [aws_iam_role_policy_attachment.codebuild_ecr_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment)         | resource    |
| [aws_iam_role_policy_attachment.codepipeline_policy_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment)   | resource    |
| [aws_s3_bucket.artifact_store](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket)                                                 | resource    |
| [aws_s3_bucket_versioning.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning)                                     | resource    |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity)                                         | data source |

## Inputs

| Name                                                                              | Description                                                                             | Type     | Default       | Required |
| --------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------- | -------- | ------------- | :------: |
| <a name="input_app_name"></a> [app_name](#input_app_name)                         | Name of application used in naming resources including ECR, CodeCommit, CodeBuild, etc. | `string` | `"myapp"`     |    no    |
| <a name="input_region"></a> [region](#input_region)                               | AWS Region                                                                              | `string` | `"us-east-1"` |    no    |
| <a name="input_s3_force_destroy"></a> [s3_force_destroy](#input_s3_force_destroy) | Delete S3 bucket contents when deleting the bucket                                      | `bool`   | `false`       |    no    |

## Outputs

| Name                                                                                      | Description                                                                                         |
| ----------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------- |
| <a name="output_clone_url_http"></a> [clone_url_http](#output_clone_url_http)             | The URL to use for cloning the repository over HTTPS.                                               |
| <a name="output_clone_url_ssh"></a> [clone_url_ssh](#output_clone_url_ssh)                | The URL to use for cloning the repository over SSH.                                                 |
| <a name="output_ecr_repository_url"></a> [ecr_repository_url](#output_ecr_repository_url) | The URL of the repository (in the form aws_account_id.dkr.ecr.region.amazonaws.com/repositoryName). |

# Cost Breakdown

```
tpulliam@lappy terraform-code-pipeline % infracost breakdown --path .
Evaluating Terraform directory at .
  ✔ Downloading Terraform modules
  ✔ Evaluating Terraform directory
  ✔ Retrieving cloud prices to calculate costs

Project: .

 Name                                             Monthly Qty  Unit                    Monthly Cost

 aws_cloudwatch_log_group.this
 ├─ Data ingested                           Monthly cost depends on usage: $0.50 per GB
 ├─ Archival Storage                        Monthly cost depends on usage: $0.03 per GB
 └─ Insights queries data scanned           Monthly cost depends on usage: $0.005 per GB

 aws_codebuild_project.this
 └─ Linux (general1.small)                  Monthly cost depends on usage: $0.005 per minutes

 aws_ecr_repository.this
 └─ Storage                                 Monthly cost depends on usage: $0.10 per GB

 aws_s3_bucket.artifact_store
 └─ Standard
    ├─ Storage                              Monthly cost depends on usage: $0.023 per GB
    ├─ PUT, COPY, POST, LIST requests       Monthly cost depends on usage: $0.005 per 1k requests
    ├─ GET, SELECT, and all other requests  Monthly cost depends on usage: $0.0004 per 1k requests
    ├─ Select data scanned                  Monthly cost depends on usage: $0.002 per GB
    └─ Select data returned                 Monthly cost depends on usage: $0.0007 per GB

 OVERALL TOTAL                                                                                $0.00
──────────────────────────────────
18 cloud resources were detected:
∙ 4 were estimated, all of which include usage-based costs, see https://infracost.io/usage-file
∙ 12 were free, rerun with --show-skipped to see details
∙ 2 are not supported yet, rerun with --show-skipped to see details

┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┳━━━━━━━━━━━━━━┓
┃ Project                                            ┃ Monthly cost ┃
┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╋━━━━━━━━━━━━━━┫
┃ .                                                  ┃ $0.00        ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┻━━━━━━━━━━━━━━┛
```
