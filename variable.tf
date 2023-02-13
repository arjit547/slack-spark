################# PROJECT #####################
variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "us-east-1"
}
variable "account" {
  default = "875525659788"
}
variable "env" {
  description = "Targeted Depolyment environment"
  default     = "dev"
}
variable "project"{
    description = "This is  project name"
    default = "sparkaseekerapi"
}
variable "hosted_zone_id"{
    description = "This is  domain name"
    default = "Z08943592C3G91ZXS79XC"
    type = string
}
################# GITHUB ##################
variable "github_token" {
    description = "This is github authentication token"
    default = "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"
    type = string
}
variable "github_owner" {
    description = "This is github repository owner or user"
    default = "arjit547"
    type = string
}
variable "github_repo" {
    description = "This is github repository name"
    default = "api"
    type = string
}
variable "github_branch" {
    description = "This is github branch to deploy"
    default = "dev"
}

################# PIPELINE ##################
variable "artifacts_bucket_name" {
  description = "S3 Bucket for storing artifacts"
  default     = "sparkseeker-artifacts"
}


################# SECUIRITY ##################
variable "vpc_id" {
  default     = "vpc-02e61a23c2679e0c2"
  description = "default vpc for cluster"
}

variable "public_subnet1" {
  default     = "subnet-07b19683195251e38"
  description = "custom subnet 1 for cluster"
}
variable "public_subnet2" {
  default     = "subnet-0b38fb9defc371e1b"
  description = "custom subnet 2 for cluster"
}
variable "health_check_path" {
  default = "/"
}
variable "app_port" {
  default     = "3000"
  description = "portexposed on the docker image"
}

################# ECS ##################
variable "cluster_name" {
  default     = "sparkseekerapi-dev"
  description = "portexposed on the docker image"
}
variable "aws_ecs_app_service_name" {
  description = "Target Amazon ECS Cluster NodeJs App Service name"
  default     = "sparkseekerapi-microservice"
}
variable "az_count" {
  default     = "2"
  description = "number of availability zones in above region"
}
variable "ecs_task_execution_role" {
  default     = "ECcsTaskExecutionServiceRoleForSparkseeker"
  description = "ECS task execution role name"
}
variable "app_count" {
  default     = "1" #choose 2 bcz i have choosen 2 AZ
  description = "numer of docker dev_containers to run"
}
variable "fargate_cpu" {
  default     = "256"
  description = "fargate instacne CPU units to provision,my requirent 1 vcpu so gave 1024"
}
variable "fargate_memory" {
  default     = "512"
  description = "Fargate instance memory to provision (in MiB) not MB"
}

########################### APP ###########################
variable "user_dev_container"{
    description = "This is github branch to deploy"
    default = "user-dev"
    type = string
}
variable "user_port" {
  default     = "3000"
}
variable "user_log_group_name" {
  default     = "/ecs/user-dev"
}
variable "user_directory" {
  default     = "user"
}
variable "user_domain_name"{
    description = "This is  domain name"
    default = "devuser.sparkseekerapi.com"
    type = string
}

################# ADMIN #######################
variable "admin_dev_container"{
    description = "This is admin dev_container for ecs task def"
    default = "admin-dev"
    type = string
}
variable "admin_port" {
  default     = "3000"
}
variable "admin_log_group_name" {
  default     = "/ecs/admin-dev"
}
variable "admin_directory" {
  default     = "admin"
}
variable "admin_domain_name"{
    description = "This is  domain name"
    default = "devadmin.sparkseekerapi.com"
    type = string
}

################## SPARK ######################
variable "spark_dev_container"{
    description = "This is github branch to deploy"
    default = "spark-dev"
    type = string
}
variable "spark_port" {
  default     = "3000"
}
variable "spark_log_group_name" {
  default     = "/ecs/spark-dev"
}
variable "spark_directory" {
  default     = "spark"
}
variable "spark_domain_name"{
    description = "This is  domain name"
    default = "sparkdev.sparkseekerapi.com"
    type = string
}

################### STREAM #####################
variable "stream_dev_container"{
    description = "This is stream dev_container ecs task def"
    default = "stream-dev"
    type = string
}
variable "stream_port" {
  default     = "3000"
}
variable "stream_log_group_name" {
  default     = "/ecs/stream-dev"
}
variable "stream_directory" {
  default     = "stream"
}
variable "stream_domain_name"{
    description = "This is  domain name"
    default = "streamdev.sparkseekerapi.com"
    type = string
}
################### CHAT #####################
variable "chat_dev_container"{
    description = "This is chat dev_container for ecs task def"
    default = "chat-dev"
    type = string
}
variable "chat_port" {
  default     = "3000"
}
variable "chat_log_group_name" {
  default     = "/ecs/chat-dev"
}
variable "chat_directory" {
  default     = "chat"
}
variable "chat_domain_name"{
    description = "This is  domain name"
    default = "chatdev.sparkseekerapi.com"
    type = string
}
#################### NOTIFICATION ####################
variable "notification_dev_container"{
    description = "notification dev_container for ecs task"
    default = "notification-dev"
    type = string
}
variable "notification_port" {
  default     = "3000"
}
variable "notification_log_group_name" {
  default     = "/ecs/notification-dev"
}
variable "notification_directory" {
  default     = "notification"
}
variable "notification_domain_name"{
    description = "This is  domain name"
    default = "notificationdev.sparkseekerapi.com"
    type = string
}
########################################
