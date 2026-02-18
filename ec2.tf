# Key pair login
resource "aws_key_pair" "terra-key" {
  key_name   = "terra-key-ec2"
  public_key = file("terra-key.pub")
}
# VPC and security group
resource "aws_default_vpc" "default"{
    tags = {
      Name: "default_vpc"
    }
}

resource "aws_security_group" "automated-sg"{
    name = "automated-sg"
    description = "sg using terraform"
    vpc_id = aws_default_vpc.default.id
    # inbound rules
    ingress{
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]
        description = "ssh port open"
    }

    ingress{
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]
        description = "http port open"
    }
    ingress{
        from_port = 8000
        to_port = 8000
        protocol = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]
        description = "app port open"
    }

    # outbound rules
    egress{
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = [ "0.0.0.0/0" ]
        description = "outbound rules open for all"
    }
} 

# ec2 instance 

resource "aws_instance" "terraform-ec2"{
    key_name = aws_key_pair.terra-key.key_name
    for_each = tomap({
        ansible-master = "ami-019715e0d74f695be" #ubuntu
        ansible-node-1 = "ami-0ffef61f6dc37ae89" #redhat
        ansible-node-2 = "ami-0a15c80c30715cc92" #debian
        ansible-node-3 = "ami-019715e0d74f695be" #ubuntu
    })
    security_groups = [ aws_security_group.automated-sg.name ]
    instance_type = "t2.micro"
    ami = each.value
    root_block_device {
      volume_size = 10
      volume_type = "gp3"
    }
    depends_on = [ aws_default_vpc.default, aws_key_pair.terra-key, aws_security_group.automated-sg ]
    user_data = file("init.sh")
    tags = {
        Name = each.key
    }
}



