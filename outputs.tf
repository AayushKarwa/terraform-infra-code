output "ec2_full_details" {
  value = {
    for key, instance in aws_instance.terraform-ec2 :
    key => {
      public_ip  = instance.public_ip
      private_ip = instance.private_ip
      ami_id     = instance.ami
      instance_type = instance.instance_type
      ssh_user   = local.instance_config[key].ssh_user
    }
  }
}