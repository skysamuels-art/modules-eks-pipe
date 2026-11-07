data "aws_key_pair" "jenkins" {
  key_name = var.key_pair_name
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_security_group" "jenkins" {
  name_prefix = "${var.project_name}-jenkins-"
  description = "Jenkins controller access"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from administrator"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.admin_cidrs
  }

  ingress {
    description = "Jenkins access from private subnets"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = var.private_subnet_cidrs
  }

    ingress {
    description = "Jenkins web access from administrator"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = var.admin_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-jenkins"
  }
}

resource "aws_instance" "jenkins" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.small"
  subnet_id                   = var.public_subnet_id
  key_name                    = data.aws_key_pair.jenkins.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.jenkins.id]

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 30
    encrypted             = true
    delete_on_termination = true
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = {
    Name = "${var.project_name}-jenkins"
  }
}