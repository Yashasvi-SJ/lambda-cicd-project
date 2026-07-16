provider "aws" {
  region = "us-east-1"
}

# 1. S3 Bucket
resource "aws_s3_bucket" "artifact_bucket" {
  bucket = "my-cicd-artifact-bucket-123456"
}

# 2. IAM Role
resource "aws_iam_role" "codebuild_role" {
  name = "codebuild-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "codebuild.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role" "codepipeline_role" {
  name = "codepipeline-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "codepipeline.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

# 3. CodeBuild
resource "aws_codebuild_project" "build_project" {
  name         = "lambda-build"
  service_role = aws_iam_role.codebuild_role.arn

  artifacts {
    type     = "S3"
    location = aws_s3_bucket.artifact_bucket.bucket
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/standard:5.0"
    type         = "LINUX_CONTAINER"
  }

  source {
    type      = "GITHUB"
    location  = "https://github.com/Yashasvi-SJ/lambda-cicd-project.git"
    buildspec = "buildspec.yml"
  }
}

# 👇👇👇 ADD STEP 11 HERE 👇👇👇

resource "aws_codepipeline" "pipeline" {
  name     = "my-pipeline"
  role_arn = aws_iam_role.codebuild_role.arn

  artifact_store {
    location = aws_s3_bucket.artifact_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      output_artifacts = ["source_output"]
      version = "1"

      configuration = {
        Owner      = "Yashasvi-SJ"
        Repo       = "lambda-cicd-project"
        Branch     = "main"
        OAuthToken = var.github_token
      }
    }
  }

  stage {
    name = "Build"

    action {
      name            = "Build"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["source_output"]
      version = "1"

      configuration = {
        ProjectName = aws_codebuild_project.build_project.name
      }
    }
  }
}