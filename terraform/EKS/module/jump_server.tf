#########################################
# Get latest Ubuntu 22.04 AMI
#########################################

data "aws_ami" "ubuntu" {

  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

#########################################
# Security Group for Jump Server
#########################################

resource "aws_security_group" "jump_server_sg" {

  name        = "${var.cluster_name}-jump-sg"
  description = "Allow SSH access to jump server"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {

    from_port   = 0
    to_port     = 0
    protocol    = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.cluster_name}-jump-sg"
    Env  = var.env
  }
}

#########################################
# Jump Server Instance
#########################################

resource "aws_instance" "jump_server" {

  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  subnet_id = aws_subnet.public_subnet[0].id
  key_name  = "eks-key-tf"

  vpc_security_group_ids = [
    aws_security_group.jump_server_sg.id
  ]

  associate_public_ip_address = true

  #########################################
  # User Data Script
  #########################################

  user_data = <<-EOF
              #!/bin/bash
              set -e

              apt-get update -y
              apt-get upgrade -y

              apt-get install -y \
                curl \
                unzip \
                git \
                apt-transport-https \
                ca-certificates \
                gnupg

              ################################
              # Install AWS CLI v2
              ################################
              curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
              unzip awscliv2.zip
              ./aws/install

              ################################
              # Install kubectl
              ################################
              curl -LO "https://dl.k8s.io/release/v1.33.0/bin/linux/amd64/kubectl"
              chmod +x kubectl
              mv kubectl /usr/local/bin/

              ################################
              # Install Helm
              ################################
              curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

              EOF

  tags = {
    Name = "${var.cluster_name}-jump-server"
    Env  = var.env
  }
}

#########################################
# Output Jump Server Public IP
#########################################

output "jump_server_public_ip" {
  value = aws_instance.jump_server.public_ip
}