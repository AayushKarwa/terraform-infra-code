output "ec2_public_ip" {
  value = {
    for key, instance in aws_instance.terraform-ec2: 
    key => instance.public_ip
  }
}

output "ec2_public_dns" {
  value = {
    for key, instance in aws_instance.terraform-ec2: 
    key => instance.public_dns
  }
}

output "ec2_private_ip" {
  value = {
    for key, instance in aws_instance.terraform-ec2 :
    key => instance.private_ip
  }
}