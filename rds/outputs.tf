output "password" {
  sensitive = true
  value     = random_password.password.result
}

output "password_url_encode" {
  sensitive = true
  value     = urlencode(random_password.password.result)
}

output "username" {
  value = aws_db_instance.this.username
}

output "host" {
  value = aws_db_instance.this.address
}

output "port" {
  value = aws_db_instance.this.port
}

output "arn" {
  value = aws_db_instance.this.arn
}

output "db_name" {
  value = aws_db_instance.this.db_name
}
