output "root_username" {
  value = aws_db_instance.this.username
}

output "root_password" {
  sensitive = true
  value     = random_password.root_password.result
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
