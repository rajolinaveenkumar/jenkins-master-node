resource "aws_instance" "jenkins_master" {
  instance_type          = "t3.small"
  vpc_security_group_ids = ["sg-087f3838223040db0"]
  subnet_id = "subnet-0f56388cad5462a78"
  ami = data.aws_ami.ami_info.id
  user_data = file("jenkins.sh")

  # 20GB is not enough
  root_block_device {
    volume_size = 50       # Size of the root volume in GB
    volume_type = "gp3"    # General Purpose SSD (you can change it if needed)
    delete_on_termination = true  # Automatically delete the volume when the instance is terminated
  }  
  tags = {
    Name    = "jenkins"
  }
}

resource "aws_instance" "jenkins_node" {
  instance_type          = "t3.small"
  vpc_security_group_ids = ["sg-087f3838223040db0"]
  subnet_id = "subnet-0f56388cad5462a78"
  ami = data.aws_ami.ami_info.id
  user_data = file("jenkins-agent.sh")

  # 20GB is not enough
  root_block_device {
    volume_size = 50       # Size of the root volume in GB
    volume_type = "gp3"    # General Purpose SSD (you can change it if needed)
    delete_on_termination = true  # Automatically delete the volume when the instance is terminated
  }  
  tags = {
    Name    = "jenkins-agent"
  }
}

module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "~> 2.0"

  zone_name = var.zone_name

  records = [
    {
      name    = "jenkins"
      type    = "A"
      ttl     = 1
      records = [
        aws_instance.jenkins_master.public_ip
      ]
      allow_overwrite = true
    },
    {
      name    = "jenkins-agent"
      type    = "A"
      ttl     = 1
      records = [
        aws_instance.jenkins_node.private_ip
      ]
      allow_overwrite = true
    }
  ]

}