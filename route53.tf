 ###################### ROUTE53 #############################
resource "aws_route53_record" "www_user" {
  zone_id = var.hosted_zone_id
  name    = var.user_domain_name
  type    = "A"
  # ttl     = "60"
  # records = [aws_cloudfront_distribution.s3_distribution.domain_name]
  alias {
    name                   = aws_alb.ecsapp_alb.dns_name
    zone_id                = aws_alb.ecsapp_alb.zone_id
    evaluate_target_health = true
  }

}
resource "aws_route53_record" "www_admin" {
  zone_id = var.hosted_zone_id
  name    = var.admin_domain_name
  type    = "A"
  # ttl     = "60"
  # records = [aws_cloudfront_distribution.s3_distribution.domain_name]
  alias {
    name                   = aws_alb.ecsapp_alb.dns_name
    zone_id                = aws_alb.ecsapp_alb.zone_id
    evaluate_target_health = true
  }

}
resource "aws_route53_record" "www_spark" {
  zone_id = var.hosted_zone_id
  name    = var.spark_domain_name
  type    = "A"
  # ttl     = "60"
  # records = [aws_cloudfront_distribution.s3_distribution.domain_name]
  alias {
    name                   = aws_alb.ecsapp_alb.dns_name
    zone_id                = aws_alb.ecsapp_alb.zone_id
    evaluate_target_health = true
  }

}
resource "aws_route53_record" "www_chat" {
  zone_id = var.hosted_zone_id
  name    = var.chat_domain_name
  type    = "A"
  # ttl     = "60"
  # records = [aws_cloudfront_distribution.s3_distribution.domain_name]
  alias {
    name                   = aws_alb.ecsapp_alb.dns_name
    zone_id                = aws_alb.ecsapp_alb.zone_id
    evaluate_target_health = true
  }

}
resource "aws_route53_record" "www_stream" {
  zone_id = var.hosted_zone_id
  name    = var.stream_domain_name
  type    = "A"
  # ttl     = "60"
  # records = [aws_cloudfront_distribution.s3_distribution.domain_name]
  alias {
    name                   = aws_alb.ecsapp_alb.dns_name
    zone_id                = aws_alb.ecsapp_alb.zone_id
    evaluate_target_health = true
  }

}
resource "aws_route53_record" "www_notification" {
  zone_id = var.hosted_zone_id
  name    = var.notification_domain_name
  type    = "A"
  # ttl     = "60"
  # records = [aws_cloudfront_distribution.s3_distribution.domain_name]
  alias {
    name                   = aws_alb.ecsapp_alb.dns_name
    zone_id                = aws_alb.ecsapp_alb.zone_id
    evaluate_target_health = true
  }

}