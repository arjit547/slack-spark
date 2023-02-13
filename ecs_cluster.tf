resource "aws_ecs_cluster" "sparkseeker_cluster" {
  name = var.cluster_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}