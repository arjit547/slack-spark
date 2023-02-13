# Project's Title- 
 Sparkseeker-terraform-Terraform Module for sparkseeker for dev environment api's using CI/CD with AWS Code Pipeline and Code Build using GitHub.
 
# Requirements-  
Docker
AWS Account
GitHub

# Project Description - 
For each AWS CodePipeline, there are 3 stages:

Source Stage (GitHub)
Build (AWS CodeBuild)
Deploy to ECS Cluster 

We will be using the following AWS Services in an AWS Region of your choice, please make sure the region that you select has the following AWS services:

Amazon S3
IAM Role Policies
Security Groups
AWS CodePipeline
AWS CodeBuild
Elastic Container Service (ECS)
Elastic Container Registry (ECR)
Amazon Application Load Balancer

It is assumed that you already have an AWS account and have a VPC to deploy ECS. It is also assumed that you have some familiarity with GitHub & Docker and AWS services like VPC, ELB & EC2.

# ECS CONCEPTS
Let's get familiar with some ECS concepts and terms.

Cluster : The cluster is a skeleton structure around which you build and operate workloads. EC2 container instances logically belong to it.

Container Instance/s : This is actually an EC2 instance running Docker daemon and the ECS agent (Container agent). The recommended option is to use AWS ECS AMI but any AMI can be used as long as you add the ECS agent to it. The ECS agent is open source as well.

Container Agent : The agent that runs on EC2 instances to form the ECS cluster. If you are using the ECS optimised AMI, then you don't need to do anything as the agent comes with it. But if you want run your own OS/AMI, you will need to install the agent. The container agent is open source and can be found at https://github.com/aws/amazon-ecs-agent.

Task Definition : An application containing one or more containers. This is where you provide the Docker images, how much CPU/Memory to use, ports etc. You can also link containers here similar to Docker command line.

Service : A service in ECS allows you to run and maintain a specified number of instances of a task definition. If a task in a service stops, the task is restarted. Services ensure that desired running tasks is achieved and maintained. Services can also include things like load balancer configuration, IAM roles and placement strategies.

Task : An instance of a task definition running on a container instance. . The key difference is that task definitions do not belong to a cluster or a service. They are just definitions in your ECS setup. When you include them in a service they become tasks and run on the container instances belonging to your ECS cluster

Container : A Docker container that is executed as part of a task.

Service Auto Scaling : This is similar to the EC2 auto scaling concept but applies to the number of containers you are running for each service.The ECS service scheduler respects the desired count at all times. In addition, a scaling policy can be configured to trigger a scale out based on alarms.

# Prepare IAM Roles
AWS provides pre-configured roles that you can use. The recomendation is to create a custom role called ECS and attach the following policies to this

 CODE BUILD ROLE, 
 CODE PIPELINE ROLE, 
 ECS TASK EXECUTION ROLE,
 CODE BUILD POLICY,
 CODE PIPELINE POLICY,
 ECS TASK EXECUTION POLICY,
 ECS task execution role policy attachment

# Prepare Security Groups
Create a security groups named alb_sg In this group, allow port 80,443 on inbound.

Create a security group named ecs_sg In this group, allow Traffic to the ECS cluster should only come from the ALB.

In both groups, you can allow other ports if you need.

# Prepare Application Load Balancer (ALB)
ECS will work with both classic load balancers and application load balancers. Application load balancer (ALB) is the best fit for ECS because of features likes dynamic ports, url based target groups etc. For this code we will create Single ALB balancer for all the six api's(ECS Service) with different target groups and listner rules for http and https.
You have to decide on the ports you will use for the services. In our code, we choose port 3000 for the a service. This port number is defined separately at all layers; load balancer, task definition, service definition and the actual listener port inside the container. So, it needs to match.

Create a Single Application load balancer that listens on port 80 and choose the appropriate subnets as per your VPC.


Services- Admin, Chat, Notification, Spark, Stream, User
Each service file consists of ECR repo, Ecs task definition template file(image.json), ECS Service with network configuration and load balancer then have codebuild with the buildspec.yaml file and codepipeline with its three stages.

# Buildspec.yaml file
Buildspec files must be expressed in YAML format.If a command contains a character, or a string of characters, that is not supported by YAML

This is our buildspec file syntax used for dev environment with Dockerfile.
Includes phase of prebuild commands- Get login in our aws ecr and dockerhub.
Build commands- Build the image using dockerfile and image tag
post-build commands- Push the image into our aws account and the the artifacts

version: 0.2

phases:
  pre_build:
    commands:
      - echo Logging in to Amazon ECR.........
      
  build:
    commands:
      - echo Build started on `date`...........
            
  post_build:
    commands:
      - echo Build completed on `date`.........
     
artifacts:
    files: $FILENAME

# Provider.tf - 
 provider includes the aws credentials to link your terraform with the aws account
    profile = "XXXXXXX"
    region = XXXXXXXXX

# dev.out
Stores the terraform plan output in this file.
 
 
# Route53
Contains the hosted zones of different services.
A hosted zone is a container for records, and records contain information about how you want to route traffic for a specific domain, such as sparkseekerapi.com, and its subdomains (sparkdev.sparkseekerapi.com, chatdev.sparkseekerapi.com). A hosted zone and the corresponding domain have the same name.

# Variables

# Name
Project
(region, account, env, project, hosted_zoneid)

Github
(Github_token, owner, repo, branch)

Pipeline	                            	
(artifact_bucket_name)

Security
(Vpc, subnets, healthcheck, app_port)

ECS	                  	
(cluster_name, aws_ecs_app_service_name, az_count, ecs_task_execution_role, app_count, fargate_cpu, fargate_memory)	                       	
                           
App- User, admin, chat, notification, spark, stream
(dev_container, port, log_group_name, directory, domain_name)


# Terraform Commands

 terraform-init        Run terraform init

 terraform-plan        Run terraform plan -out dev.out 

 terraform-apply       Run terraform apply "dev.out" 
        
 terraform-destroy     Run terraform plan -out dev.out -destroy 

 clean                 Clean .terraform




