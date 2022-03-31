output "security_group_id" {
  value = aws_security_group.alb.id
}

output "alb_dns_name" {
  value = aws_lb.this.dns_name
}

output "https_listener_arn" {
  value = aws_lb_listener.https.arn
}

output "http_listener_arn" {
  value = aws_lb_listener.http.arn
}
