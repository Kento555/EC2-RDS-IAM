resource "aws_instance" "ec2_instance" {
  ami                         = data.aws_ami.latest_amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = length(data.aws_subnets.public_subnets.ids) > 0 ? tolist(data.aws_subnets.public_subnets.ids)[0] : null
  vpc_security_group_ids      = [aws_security_group.instance_sg.id]
  key_name                    = data.aws_key_pair.ws_keypair.key_name
  associate_public_ip_address = true
  count                       = var.instance_count
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y mysql jq aws-cli
              echo "Connecting to RDS at ${aws_db_instance.rds.endpoint}" > /home/ec2-user/db.log
              
              # Retrieve secret from AWS Secrets Manager
              SECRET_JSON=$(aws secretsmanager get-secret-value --secret-id ${aws_secretsmanager_secret.rds_secret.id} --query SecretString --output text)
              DB_USER=$(echo $SECRET_JSON | jq -r '.username')
              DB_PASSWORD=$(echo $SECRET_JSON | jq -r '.password')
              DB_HOST=$(echo $SECRET_JSON | jq -r '.host')

              echo "Connecting to RDS at $DB_HOST with user $DB_USER" > /home/ec2-user/db.log
              mysql -h $DB_HOST -u $DB_USER -p$DB_PASSWORD -e "SHOW DATABASES;" >> /home/ec2-user/db.log
              EOF

  tags = {
    Name = "${var.name_prefix}-ec2-rds"
  }
}

