# Store the RDS password in AWS Secrets Manager and retrieve it automatically in EC2.
resource "aws_secretsmanager_secret" "rds_secret" {
  name = "rds-password-secret"
}

resource "aws_secretsmanager_secret_version" "rds_secret_version" {
  secret_id = aws_secretsmanager_secret.rds_secret.id

  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
    host     = aws_db_instance.rds.endpoint
  })
}

output "secret_arn" {
  value = aws_secretsmanager_secret.rds_secret.arn
}

# Store Credentials in .tfvars but not in GIT (e.g: Create a file of credential.tfvars)
# This file stores sensitive values outside the main .tf files
# inside the .tvars file, create db_username = "<your_username>", db_password = "<your_password>"
# These variables will reference values from terraform.tfvars
variable "db_username" {
  description = "The database admin username"
  type        = string
}

variable "db_password" {
  description = "The database admin password"
  type        = string
  sensitive   = true  # Hides password in logs
}



