variable "aws_region" {
  default = "ap-south-1"
}

variable "s3_bucket_prefix" {}
variable "s3_bucket_name" {}
variable "environment" {}

variable "vpc_cidr" {}
variable "vpc_name" {}

variable "subnet_cidr" {}
variable "availability_zone" {}
variable "subnet_name" {}

variable "igw_name" {}
variable "route_table_name" {}

variable "sg_name" {}
variable "sg_description" {}
variable "allowed_ssh_cidrs" {
  type = list(string)
}
variable "allowed_http_cidrs" {
  type = list(string)
}
variable "sg_tag_name" {}

variable "ec2_ami" {}
variable "ec2_instance_type" {}
variable "key_name" {}
variable "ec2_name" {}



provider "aws" {
  region = var.aws_region
}



resource "random_id" "rand" {
  byte_length = 4
}

resource "aws_s3_bucket" "tushar_bucket" {
  bucket = "${var.s3_bucket_prefix}-${random_id.rand.hex}"

  tags = {
    Name        = var.s3_bucket_name
    Environment = var.environment
  }
}

resource "aws_vpc" "tushar_vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_subnet" "tushar_subnet" {
  vpc_id                  = aws_vpc.tushar_vpc.id
  cidr_block              = var.subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = var.subnet_name
  }
}

resource "aws_internet_gateway" "tushar_igw" {
  vpc_id = aws_vpc.tushar_vpc.id

  tags = {
    Name = var.igw_name
  }
}

resource "aws_route_table" "tushar_rt" {
  vpc_id = aws_vpc.tushar_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tushar_igw.id
  }

  tags = {
    Name = var.route_table_name
  }
}

resource "aws_route_table_association" "tushar_rta" {
  subnet_id      = aws_subnet.tushar_subnet.id
  route_table_id = aws_route_table.tushar_rt.id
}

resource "aws_security_group" "tushar_sg" {
  name        = var.sg_name
  description = var.sg_description
  vpc_id      = aws_vpc.tushar_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidrs
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.allowed_http_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.sg_tag_name
  }
}

resource "aws_instance" "tushar_ec2" {
  ami                         = var.ec2_ami
  instance_type               = var.ec2_instance_type
  subnet_id                   = aws_subnet.tushar_subnet.id
  vpc_security_group_ids      = [aws_security_group.tushar_sg.id]
  associate_public_ip_address = true
  key_name                    = var.key_name

  tags = {
    Name = var.ec2_name
  }
}
