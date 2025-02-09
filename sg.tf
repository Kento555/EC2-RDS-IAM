# Define Security Groups Without Rules
resource "aws_security_group" "instance_sg" {
  name        = "instance-sg"
  description = "Allow inbound traffic for EC2"
  vpc_id      = var.vpc_id
}

resource "aws_security_group" "db_sg" {
  name        = "db-sg"
  description = "Allow inbound traffic for RDS"
  vpc_id      = var.vpc_id
}

#  Define Security Group Rules Separately
# Allow EC2 (instance_sg) to access RDS (db_sg) on port 3306
resource "aws_security_group_rule" "rds_ingress" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.db_sg.id
  source_security_group_id = aws_security_group.instance_sg.id
}

# Allow outgoing traffic from RDS (db_sg)
resource "aws_security_group_rule" "rds_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol         = "-1"
  security_group_id = aws_security_group.db_sg.id
  cidr_blocks      = ["0.0.0.0/0"]
}

# Allow SSH (22) and HTTP (80) access to EC2 from anywhere
resource "aws_security_group_rule" "instance_ingress_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol         = "tcp"
  security_group_id = aws_security_group.instance_sg.id
  cidr_blocks      = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "instance_ingress_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol         = "tcp"
  security_group_id = aws_security_group.instance_sg.id
  cidr_blocks      = ["0.0.0.0/0"]
}

# Allow all outbound traffic from EC2
resource "aws_security_group_rule" "instance_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol         = "-1"
  security_group_id = aws_security_group.instance_sg.id
  cidr_blocks      = ["0.0.0.0/0"]
}

