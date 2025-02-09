# Create RDS instance in Private Subnet 
# Can be only accessed by EC2 inside same VPC
resource "aws_db_instance" "rds" {
  allocated_storage      = 20
  engine                 = "mysql"
  instance_class         = "db.t3.micro"
  db_name                = "mydatabase"
  username               = var.db_username
  password               = var.db_password
  skip_final_snapshot    = true
  publicly_accessible    = false
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.mydb_subnet.name

  tags = {
    Name = "${var.name_prefix}-db-rds"
  }
}


resource "aws_db_subnet_group" "mydb_subnet" {
  name       = "mydb-subnet"
  subnet_ids = data.aws_subnets.private_subnets.ids   
#   subnet_ids = length(data.aws_subnets.private_subnets.ids) > 0 ? data.aws_subnets.private_subnets.ids : ["subnet-034d8630d129a1fb4", "subnet-08075f7fa3627e3ad","subnet-0b536fdad4933cdd3"] 
# # Above line use to replace with actual subnet IDs if subnet id return empty list
}


output "rds_endpoint" {
  value = aws_db_instance.rds.endpoint
}