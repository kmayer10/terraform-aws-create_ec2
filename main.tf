data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

data "aws_vpc" "aws_vpc" {
  default = true
}

locals {
  Name = "${var.client}-${var.project}"
}

resource "aws_security_group" "aws_security_group" {
  vpc_id = data.aws_vpc.aws_vpc.id
  name = local.Name
  description = "Security group created using Terraform for ${local.Name}"
  tags = {
    Name = local.Name
  }
  egress = [ {
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "all open"
    from_port = 0
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    protocol = "-1"
    security_groups = []
    self = false
    to_port = 0
  } ]
  dynamic "ingress" {
    for_each = var.ingress
    content {
      self = lookup(ingress.value, "self", null)
      from_port = lookup(ingress.value, "from_port", 0)
      to_port = lookup(ingress.value, "to_port", 0)
      cidr_blocks = lookup(ingress.value, "cidr_blocks", null)
      protocol = lookup(ingress.value, "protocol", -1)
      description = lookup(ingress.value, "description", null)
    }
  }
}

resource "aws_instance" "ec2" {
  ami = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name = var.key_name
  tags = {
    Name = local.Name
    client = var.client
    project = var.project
  }
  root_block_device {
    volume_size = var.root_volume_size
    volume_type = "gp2"
    delete_on_termination = true
  }
  vpc_security_group_ids = [ aws_security_group.aws_security_group.id ] 
}

resource "aws_ebs_volume" "aws_ebs_volume" {
  count = var.data_volume_needed == false ? 0 : 1
  size = var.data_volume_size
  availability_zone = aws_instance.ec2.availability_zone
  tags = {
    Name = local.Name
    client = var.client
    project = var.project
  }
}

resource "aws_volume_attachment" "aws_volume_attachment" {
  count = var.data_volume_needed == false ? 0 : 1
  volume_id = aws_ebs_volume.aws_ebs_volume[0].id
  instance_id = aws_instance.ec2.id
  device_name = "/dev/sdf"
  force_detach = true
}
