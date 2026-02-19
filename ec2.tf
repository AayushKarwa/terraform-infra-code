############################################
# LOCALS
############################################

locals {
  instance_config = {
    ansible-master = {
      ami           = "ami-019715e0d74f695be" # Ubuntu
      instance_type = "t2.medium"
      ssh_user      = "ubuntu"
    }

    ansible-node-1 = {
      ami           = "ami-0ffef61f6dc37ae89" # RedHat
      instance_type = "t2.micro"
      ssh_user      = "ec2-user"
    }

    ansible-node-2 = {
      ami           = "ami-0a15c80c30715cc92" # Debian
      instance_type = "t2.micro"
      ssh_user      = "admin"
    }

    ansible-node-3 = {
      ami           = "ami-019715e0d74f695be" # Ubuntu
      instance_type = "t2.micro"
      ssh_user      = "ubuntu"
    }
  }
}

############################################
# KEY PAIR
############################################

resource "aws_key_pair" "terra-key" {
  key_name   = "terra-key-ansible"
  public_key = file("terra-key-ansible.pub")
}

############################################
# DEFAULT VPC
############################################

resource "aws_default_vpc" "default" {
  tags = {
    Name = "default_vpc"
  }
}

############################################
# SECURITY GROUP
############################################

resource "aws_security_group" "automated-sg" {
  name        = "automated-sg"
  description = "sg using terraform"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "ssh port open"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "http port open"
  }

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "app port open"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "allow all outbound"
  }
}

############################################
# EC2 INSTANCES
############################################

resource "aws_instance" "terraform-ec2" {
  for_each = local.instance_config

  ami           = each.value.ami
  instance_type = each.value.instance_type
  key_name      = aws_key_pair.terra-key.key_name

  vpc_security_group_ids = [aws_security_group.automated-sg.id]

  root_block_device {
    volume_size = 10
    volume_type = "gp3"
  }
  instance_initiated_shutdown_behavior = "stopped"

  user_data = file("init.sh")

  tags = {
    Name = each.key
  }
}

