output "alb_hostname" {
  value = aws_alb.ecsapp_alb.dns_name
}