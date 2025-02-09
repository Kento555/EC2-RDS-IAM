resource "aws_secretsmanager_secret" "rds_secret" {
  name = "rds-password-secret"
}

resource "aws_secretsmanager_secret_version" "rds_secret_version" {
  secret_id = aws_secretsmanager_secret.rds_secret.id

  secret_string = jsonencode({
    username = "admin"
    password = "mypassword"
    host     = aws_db_instance.rds.endpoint
  })
}

output "secret_arn" {
  value = aws_secretsmanager_secret.rds_secret.arn
}
