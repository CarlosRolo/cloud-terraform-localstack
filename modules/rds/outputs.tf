output "db_endpoint" { value = "localhost:5432" }
output "db_name"     { value = "teleopsdb" }
output "security_group_id" { value = aws_security_group.rds.id }
