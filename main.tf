provider "aws" {
    region  = "ap-southeast-2"
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

resource "aws_vpc" "tfexample" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = var.name_tag
  }
}

resource "aws_internet_gateway" "tfexample" {
  vpc_id = aws_vpc.tfexample.id
  tags = {
    Name = var.name_tag
  }
}

resource "aws_subnet" "tfexample" {
  vpc_id     = aws_vpc.tfexample.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  depends_on                = [aws_internet_gateway.tfexample]

  tags = {
    Name = var.name_tag
  }
}

resource "aws_route_table" "tfexample_out" {
  vpc_id = aws_vpc.tfexample.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tfexample.id
  }

  tags = {
    Name = var.name_tag
  }
}

resource "aws_route_table_association" "tfexample_rta_out" {
  subnet_id      = aws_subnet.tfexample.id
  route_table_id = aws_route_table.tfexample_out.id
}

resource "aws_instance" "tfexample" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  private_ip = "10.0.1.10"
  subnet_id  = aws_subnet.tfexample.id
  security_groups = [ aws_security_group.tfexample_allow_ssh.id ]
  key_name = var.key_name

  tags = {
    Name = var.name_tag
  }
}

resource "aws_security_group" "tfexample_allow_ssh" {
  name        = var.name_tag
  description = "Allow SSH traffic from you"
  vpc_id      = aws_vpc.tfexample.id

  ingress {
    description = "SSH from you"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.name_tag
  }
}