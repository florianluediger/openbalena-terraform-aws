terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.38"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "eu-central-1"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "tls_private_key" "openbalena_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "openbalena_ssh_key" {
  public_key = tls_private_key.openbalena_ssh_key.public_key_openssh
}

resource "aws_security_group" "openbalena" {
  name = "allow_ssh"

  ingress {
    description = "SSH from everywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP from everywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from everywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "balena VPN from everywhere"
    from_port   = 3128
    to_port     = 3128
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_instance" "openbalena" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.xlarge"
  root_block_device {
    volume_size = 50
  }
  tags = {
    Name = "OpenBalena"
  }
  key_name        = aws_key_pair.openbalena_ssh_key.key_name
  security_groups = [aws_security_group.openbalena.name]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = tls_private_key.openbalena_ssh_key.private_key_openssh
    host        = self.public_dns
  }

  provisioner "remote-exec" {
    script = "./init.sh"
  }
}

data "aws_route53_zone" "openbalena" {
  name = var.domain_name
}

resource "aws_route53_record" "api" {
  name    = "api.${var.domain_name}"
  type    = "CNAME"
  zone_id = data.aws_route53_zone.openbalena.zone_id
  records = [aws_instance.openbalena.public_dns]
  ttl = 5
}

resource "aws_route53_record" "registry" {
  name    = "registry.${var.domain_name}"
  type    = "CNAME"
  zone_id = data.aws_route53_zone.openbalena.zone_id
  records = [aws_instance.openbalena.public_dns]
  ttl = 5
}

resource "aws_route53_record" "vpn" {
  name    = "vpn.${var.domain_name}"
  type    = "CNAME"
  zone_id = data.aws_route53_zone.openbalena.zone_id
  records = [aws_instance.openbalena.public_dns]
  ttl = 5
}

resource "aws_route53_record" "s3" {
  name    = "s3.${var.domain_name}"
  type    = "CNAME"
  zone_id = data.aws_route53_zone.openbalena.zone_id
  records = [aws_instance.openbalena.public_dns]
  ttl = 5
}

resource "aws_route53_record" "tunnel" {
  name    = "tunnel.${var.domain_name}"
  type    = "CNAME"
  zone_id = data.aws_route53_zone.openbalena.zone_id
  records = [aws_instance.openbalena.public_dns]
  ttl = 5
}