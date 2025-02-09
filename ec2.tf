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
              yum install -y mysql
              echo "Connecting to RDS at ${aws_db_instance.rds.endpoint}" > /home/ec2-user/db.log
              EOF

  tags = {
    Name = "${var.name_prefix}-ec2-rds"
  }
}

