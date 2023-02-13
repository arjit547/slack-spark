###################### ECR #############################
resource "aws_ecr_repository" "admin-dev-repo" {
  name                 = var.admin_dev_container
  image_tag_mutability = "MUTABLE"
  tags = {
    "Name" = "${var.project}-${var.env}"
  }

  image_scanning_configuration {
    scan_on_push = true
  }
}

###################### ECS TASK DEFINATION ###########################
data "template_file" "admin-dev-app" {
  template = file("./image.json")

  vars = {
    app_image      = aws_ecr_repository.admin-dev-repo.repository_url
    app_port       = var.app_port
    fargate_cpu    = var.fargate_cpu
    fargate_memory = var.fargate_memory
    aws_region     = var.aws_region
    pr_name        = var.admin_dev_container
    log_group_name = "${var.admin_log_group_name}/${var.env}"
  }
}

resource "aws_ecs_task_definition" "admin-dev-task-def" {
  family                   = var.admin_dev_container
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  container_definitions    = data.template_file.admin-dev-app.rendered
}
###################### ECS SERVICE ###########################
resource "aws_ecs_service" "admin-dev-app-service" {
  name            = var.admin_dev_container
  cluster         = var.cluster_name
  task_definition = aws_ecs_task_definition.admin-dev-task-def.arn
  desired_count   = var.app_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.ecs_sg.id]
    subnets          = [var.public_subnet1, var.public_subnet2]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.adminapi-tg.arn
    container_name   = var.admin_dev_container
    container_port   = var.app_port
  }

  depends_on = [aws_alb_listener.http, aws_iam_role_policy_attachment.ecs_task_execution_role]
}
###################### CODEBUILD ###########################
data "template_file" "admin-dev-buildspec" {
  template = file("buildspec.yml")
}
resource "aws_codebuild_project" "admin-dev-codebuild" {
  badge_enabled  = false
  build_timeout  = 60
  name           = "${var.project}-${var.admin_dev_container}"
  queued_timeout = 480
  service_role   = aws_iam_role.containerAppBuildProjectRole.arn
  tags = {
    Environment = var.env
  }

  artifacts {
    encryption_disabled = false
    # name                   = "container-app-code-${var.env}"
    # override_artifact_name = false
    packaging = "NONE"
    type      = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:5.0"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
    type                        = "LINUX_CONTAINER"

    environment_variable {
      name  = "dockerhub_username"
      value = "dockerhub:username"
      type  = "SECRETS_MANAGER"
    }

    environment_variable {
      name  = "dockerhub_password"
      value = "dockerhub:password"
      type  = "SECRETS_MANAGER"
    }
    
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }

    s3_logs {
      encryption_disabled = false
      status              = "DISABLED"
    }
  }

  source {
    buildspec           = data.template_file.admin-dev-buildspec.rendered
    git_clone_depth     = 0
    insecure_ssl        = false
    report_build_status = false
    type                = "CODEPIPELINE"
  }
}

###################### PIPELINE ###########################
resource "aws_codepipeline" "admin-dev-pipeline" {
  name     = "${var.project}-${var.admin_dev_container}"
  role_arn = aws_iam_role.apps_codepipeline_role.arn
  tags = {
    Environment = var.env
  }

  artifact_store {
    location = var.artifacts_bucket_name
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      input_artifacts  = []
      output_artifacts = ["SourceArtifact"]

      configuration = {
        Owner      = var.github_owner
        Repo       = var.github_repo
        Branch     = var.github_branch
        OAuthToken = var.github_token
      }
    }
  }
  stage {
    name = "Build"

    action {
      category = "Build"
      configuration = {
        "EnvironmentVariables" = jsonencode(
          [
            {
              name  = "environment"
              type  = "PLAINTEXT"
              value = var.env
            },
            {
              name  = "AWS_ACCOUNT_ID"
              type  = "PLAINTEXT"
              value = var.account
            },
            {
              name  = "AWS_DEFAULT_REGION"
              type  = "PLAINTEXT"
              value = var.aws_region
            },
            {
              name  = "IMAGE_REPO_NAME"
              type  = "PLAINTEXT"
              value = var.admin_dev_container
            },
            {
              name  = "IMAGE_TAG"
              type  = "PLAINTEXT"
              value = "latest"
            },
            {
              name  = "CONTAINER_NAME"
              type  = "PLAINTEXT"
              value = var.admin_dev_container
            },
            {
              name  = "DIRECTORY"
              type  = "PLAINTEXT"
              value = var.admin_directory
            },
            {
              name  = "FILENAME"
              type  = "PLAINTEXT"
              value = "adminimagedefinitions.json"
            }
          ]
        )
        "ProjectName" = aws_codebuild_project.admin-dev-codebuild.name
      }
      input_artifacts = [
        "SourceArtifact",
      ]
      name = "Build"
      output_artifacts = [
        "BuildArtifact",
      ]
      owner     = "AWS"
      provider  = "CodeBuild"
      run_order = 1
      version   = "1"
    }
  }
  stage {
    name = "Deploy"

    action {
      category = "Deploy"
      configuration = {
        "ClusterName" = var.cluster_name
        "ServiceName" = var.admin_dev_container
        "FileName"    = "adminimagedefinitions.json"
        #"DeploymentTimeout" = "15"
      }
      input_artifacts = [
        "BuildArtifact",
      ]
      name             = "Deploy"
      output_artifacts = []
      owner            = "AWS"
      provider         = "ECS"
      run_order        = 1
      version          = "1"
    }
  }

}
###################### TARGET GROUP ###########################
resource "aws_alb_target_group" "admin-dev-tg" {
  name        = "user-tg-${var.env}"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    protocol            = "HTTP"
    matcher             = "200"
    path                = var.health_check_path
    interval            = 30
  }
}

################# CLOUDWATCH ##################
resource "aws_cloudwatch_log_group" "admin-log-group-name" {
  name              = "${var.admin_log_group_name}/${var.env}"
  retention_in_days = 30

  tags = {
    Name = "cw-log-group"
  }
}

resource "aws_cloudwatch_log_stream" "admin-log-stream" {
  name           = "admin-log-stream"
  log_group_name = aws_cloudwatch_log_group.admin-log-group-name.name
}