output "ec2_public_ip" {
  value = aws_instance.ec2.public_ip
}

output "rds_endpoint" {
  value = aws_db_instance.mysql.address
}

output "db_password" {
  value     = var.db_password
  sensitive = true
}
