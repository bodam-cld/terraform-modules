output "vpc_id" {
  value = data.aws_vpc.main.id
}

output "db_subnet_group_private_name" {
  value = data.aws_db_subnet_group.private.name
}

output "security_group_private_database_id" {
  value = data.aws_security_group.private_database.id
}
