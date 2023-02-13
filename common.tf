#################### S3 BUCKET #####################
# resource "aws_s3_bucket" "cicd_bucket" {
#   bucket = "${var.artifacts_bucket_name}-${var.env}"
#   acl    = "private"
# }

#################### SECUIRITY GROUPS #######################
resource "aws_security_group" "alb_sg" {
  name        = "${var.project}-load-balancer-sg-${var.env}"
  description = "controls access to the ALB"
  vpc_id      = var.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = "80"
    to_port     = "80"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol    = "tcp"
    from_port   = "443"
    to_port     = "443"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# this security group for ecs - Traffic to the ECS cluster should only come from the ALB
resource "aws_security_group" "ecs_sg" {
  name        = "${var.project}-ecs-sg-${var.env}"
  description = "allow inbound access from the ALB only"
  vpc_id      = var.vpc_id

  
  ingress {
    protocol        = "tcp"
    from_port       = var.app_port
    to_port         = var.app_port
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
############################# LOAD BALANCER #############################

resource "aws_alb" "ecsapp_alb" {
  name           = "${var.project}-alb-${var.env}"
  subnets        = [var.public_subnet1, var.public_subnet2]
  security_groups = [aws_security_group.alb_sg.id]
}



resource "aws_alb_target_group" "userapi-tg" {
  name        = "new-userapi-tg-${var.env}"
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




resource "aws_alb_target_group" "adminapi-tg" {
  name        = "new-adminapi-tg-${var.env}"
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


resource "aws_alb_target_group" "sparkapi-tg" {
  name        = "new-sparkapi-tg-${var.env}"
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

resource "aws_alb_target_group" "chatapi-tg" {
  name        = "new-chatapi-tg-${var.env}"
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


resource "aws_alb_target_group" "streamapi-tg" {
  name        = "new-streamapi-tg-${var.env}"
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

resource "aws_alb_target_group" "notificationapi-tg" {
  name        = "new-notifyapi-tg-${var.env}"
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


resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_alb.ecsapp_alb.id
  port              = "80"
  protocol          = "HTTP"
  # ssl_policy        = "ELBSecurityPolicy-2016-08"
  # certificate_arn   = "arn:aws:acm:us-east-1:713556111830:certificate/8f8504fe-c2d2-4506-aae1-4a8fb44246ad"
  #enable above 2 if you are using HTTPS listner and change protocal from HTTP to HTTPS
  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.sparkapi-tg.arn
  }
 
}

resource "aws_alb_listener_rule" "service" {
  listener_arn = aws_alb_listener.http.arn

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.userapi-tg.arn
  }

  condition {
    host_header {
      values = [var.user_domain_name]
    }
  }
}

resource "aws_alb_listener_rule" "service1" {
  listener_arn = aws_alb_listener.http.arn
  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.adminapi-tg.arn
  }

  condition {
    host_header {
      values = [var.admin_domain_name]
    }
  }
}

resource "aws_alb_listener_rule" "service2" {
  listener_arn = aws_alb_listener.http.arn

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.sparkapi-tg.arn
  }

  condition {
    host_header {
      values = [var.spark_domain_name]
    }
  }
}

resource "aws_alb_listener_rule" "service3" {
  listener_arn = aws_alb_listener.http.arn
  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.chatapi-tg.arn
  }

  condition {
    host_header {
      values = [var.chat_domain_name]
    }
  }
}

resource "aws_alb_listener_rule" "service4" {
  listener_arn = aws_alb_listener.http.arn
  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.streamapi-tg.arn
  }

  condition {
    host_header {
      values = [var.stream_domain_name]
    }
  }
}

resource "aws_alb_listener_rule" "service5" {
  listener_arn = aws_alb_listener.http.arn
  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.notificationapi-tg.arn
  }

  condition {
    host_header {
      values = [var.notification_domain_name]
    }
  }
}


resource "aws_alb_listener" "https" {
  load_balancer_arn = aws_alb.ecsapp_alb.id
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "arn:aws:acm:us-east-1:713556111830:certificate/8f8504fe-c2d2-4506-aae1-4a8fb44246ad"
  #enable above 2 if you are using HTTPS listner and change protocal from HTTP to HTTPS
  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.userapi-tg.arn
  }
}


resource "aws_alb_listener_rule" "httpsservice" {
  listener_arn = aws_alb_listener.https.arn

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.userapi-tg.arn
  }

  condition {
    host_header {
      values = [var.user_domain_name]
    }
  }
}

resource "aws_alb_listener_rule" "httpsservice1" {
  listener_arn = aws_alb_listener.https.arn
  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.adminapi-tg.arn
  }

  condition {
    host_header {
      values = [var.admin_domain_name]
    }
  }
}

resource "aws_alb_listener_rule" "httpsservice2" {
  listener_arn = aws_alb_listener.https.arn

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.sparkapi-tg.arn
  }

  condition {
    host_header {
      values = [var.spark_domain_name]
    }
  }
}

resource "aws_alb_listener_rule" "httpsservice3" {
  listener_arn = aws_alb_listener.https.arn
  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.chatapi-tg.arn
  }

  condition {
    host_header {
      values = [var.chat_domain_name]
    }
  }
}

resource "aws_alb_listener_rule" "httpsservice4" {
  listener_arn = aws_alb_listener.https.arn
  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.streamapi-tg.arn
  }

  condition {
    host_header {
      values = [var.stream_domain_name]
    }
  }
}

resource "aws_alb_listener_rule" "httpsservice5" {
  listener_arn = aws_alb_listener.https.arn
  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.notificationapi-tg.arn
  }

  condition {
    host_header {
      values = [var.notification_domain_name]
    }
  }
}

############################# IAM ROLE #############################
################## COEDE BUILD ROLE #######################
resource "aws_iam_role" "containerAppBuildProjectRole" {
  name = "${var.project}-containerAppBuildProjectRole-codebuild-${var.env}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

################## COEDE PIPELINE ROLE #######################
resource "aws_iam_role" "apps_codepipeline_role" {
  name = "${var.project}-apps-code-pipeline-deploy-role-${var.env}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}
################## ECS TASK EXECUTION ROLE #######################
resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "${var.project}-ecs-task-execution-role-${var.env}"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_role.json
}
################## COEDE BUILD POLICY #######################
resource "aws_iam_role_policy" "containerAppBuildProjectRolePolicy" {
  role = aws_iam_role.containerAppBuildProjectRole.name

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateNetworkInterface",
        "ec2:DescribeDhcpOptions",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DeleteNetworkInterface",
        "ec2:DescribeSubnets",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeVpcs"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateNetworkInterfacePermission"
      ],
      "Resource": [
        "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": [
        "*"
      ]
    },
    {
            "Effect": "Allow",
            "Action": [
                "ecr:*"
            ],
            "Resource": "*"
    },
    {
            "Effect": "Allow",
            "Action": [
                "ecs:*"
            ],
            "Resource": "*"
    },
    {
            "Effect": "Allow",
            "Action": [
                "secretsmanager:*"
            ],
            "Resource": "*"
    },
    {
            "Effect": "Allow",
            "Action": [
                "ssm:DescribeParameters"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ssm:GetParameters"
            ],
            "Resource": "*"
        },
        {
         "Effect":"Allow",
         "Action":[
            "kms:Decrypt"
         ],
         "Resource":[
            "*"
         ]
      }
  ]
}
POLICY
}

################## COEDE PIPELINE POLICY #######################

resource "aws_iam_role_policy" "apps_codepipeline_role_policy" {
  name = "${var.project}-apps-codepipeline-role-policy-${var.env}"
  role = aws_iam_role.apps_codepipeline_role.id

  policy = <<EOF
{
    "Statement": [
        {
            "Action": [
                "iam:PassRole"
            ],
            "Resource": "*",
            "Effect": "Allow",
            "Condition": {
                "StringEqualsIfExists": {
                    "iam:PassedToService": [
                        "cloudformation.amazonaws.com",
                        "elasticbeanstalk.amazonaws.com",
                        "ec2.amazonaws.com",
                        "ecs-tasks.amazonaws.com"
                    ]
                }
            }
        },
        {
            "Action": [
                "codecommit:CancelUploadArchive",
                "codecommit:GetBranch",
                "codecommit:GetCommit",
                "codecommit:GetRepository",
                "codecommit:GetUploadArchiveStatus",
                "codecommit:UploadArchive"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "codedeploy:CreateDeployment",
                "codedeploy:GetApplication",
                "codedeploy:GetApplicationRevision",
                "codedeploy:GetDeployment",
                "codedeploy:GetDeploymentConfig",
                "codedeploy:RegisterApplicationRevision"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "codestar-connections:UseConnection"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "elasticbeanstalk:*",
                "ec2:*",
                "elasticloadbalancing:*",
                "autoscaling:*",
                "cloudwatch:*",
                "s3:*",
                "sns:*",
                "cloudformation:*",
                "rds:*",
                "sqs:*",
                "ecs:*"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "lambda:InvokeFunction",
                "lambda:ListFunctions"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "opsworks:CreateDeployment",
                "opsworks:DescribeApps",
                "opsworks:DescribeCommands",
                "opsworks:DescribeDeployments",
                "opsworks:DescribeInstances",
                "opsworks:DescribeStacks",
                "opsworks:UpdateApp",
                "opsworks:UpdateStack"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "cloudformation:CreateStack",
                "cloudformation:DeleteStack",
                "cloudformation:DescribeStacks",
                "cloudformation:UpdateStack",
                "cloudformation:CreateChangeSet",
                "cloudformation:DeleteChangeSet",
                "cloudformation:DescribeChangeSet",
                "cloudformation:ExecuteChangeSet",
                "cloudformation:SetStackPolicy",
                "cloudformation:ValidateTemplate"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "codebuild:BatchGetBuilds",
                "codebuild:StartBuild",
                "codebuild:BatchGetBuildBatches",
                "codebuild:StartBuildBatch"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Effect": "Allow",
            "Action": [
                "devicefarm:ListProjects",
                "devicefarm:ListDevicePools",
                "devicefarm:GetRun",
                "devicefarm:GetUpload",
                "devicefarm:CreateUpload",
                "devicefarm:ScheduleRun"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "servicecatalog:ListProvisioningArtifacts",
                "servicecatalog:CreateProvisioningArtifact",
                "servicecatalog:DescribeProvisioningArtifact",
                "servicecatalog:DeleteProvisioningArtifact",
                "servicecatalog:UpdateProduct"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "cloudformation:ValidateTemplate"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ecr:*"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "states:DescribeExecution",
                "states:DescribeStateMachine",
                "states:StartExecution"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "appconfig:StartDeployment",
                "appconfig:StopDeployment",
                "appconfig:GetDeployment"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ssm:DescribeParameters"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ssm:GetParameters"
            ],
            "Resource": "*"
        },
        {
         "Effect":"Allow",
         "Action":[
            "kms:Decrypt"
         ],
         "Resource":[
            "*"
         ]
      }
    ],
    "Version": "2012-10-17"
}
EOF
}

################## ECS TASK EXECUTION POLICY #######################
data "aws_iam_policy_document" "ecs_task_execution_role" {
  version = "2012-10-17"
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}


# ECS task execution role policy attachment
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
