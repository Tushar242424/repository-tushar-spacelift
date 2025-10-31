provider "aws" {

  region = "ap-south-1"

}

# Create an S3 Bucket

resource "aws_s3_bucket" "tushar_bucket" {

  bucket = "tushar-demo-bucket-${random_id.rand.hex}"

  tags = {

    Name        = "TusharBucket"

    Environment = "Dev"

  }

}

resource "random_id" "rand" {

  byte_length = 4

}

# Create a VPC

resource "aws_vpc" "tushar_vpc" {

  cidr_block = "10.0.0.0/16"

  tags = {

    Name = "TusharVPC"

  }

}

# Create a subnet inside that VPC

resource "aws_subnet" "tushar_subnet" {

  vpc_id                  = aws_vpc.tushar_vpc.id

  cidr_block              = "10.0.1.0/24"

  availability_zone       = "ap-south-1a"

  map_public_ip_on_launch = true

  tags = {

    Name = "TusharSubnet"

  }

}

# Create an Internet Gateway

resource "aws_internet_gateway" "tushar_igw" {

  vpc_id = aws_vpc.tushar_vpc.id

  tags = {

    Name = "TusharIGW"

  }

}

# Create a route table and attach to subnet

resource "aws_route_table" "tushar_rt" {

  vpc_id = aws_vpc.tushar_vpc.id

  route {

    cidr_block = "0.0.0.0/0"

    gateway_id = aws_internet_gateway.tushar_igw.id

  }

  tags = {

    Name = "TusharRouteTable"

  }

}

resource "aws_route_table_association" "tushar_rta" {

  subnet_id      = aws_subnet.tushar_subnet.id

  route_table_id = aws_route_table.tushar_rt.id

}

# Create a security group

resource "aws_security_group" "tushar_sg" {

  name        = "tushar-sg"

  description = "Allow SSH and HTTP"

  vpc_id      = aws_vpc.tushar_vpc.id

  ingress {

    from_port   = 22

    to_port     = 22

    protocol    = "tcp"

    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {

    from_port   = 80

    to_port     = 80

    protocol    = "tcp"

    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {

    from_port   = 0

    to_port     = 0

    protocol    = "-1"

    cidr_blocks = ["0.0.0.0/0"]

  }

  tags = {

    Name = "TusharSecurityGroup"

  }

}

# Create EC2 Instance

resource "aws_instance" "tushar_ec2" {

  ami                    = "ami-0dee22c13ea7a9a67" # Ubuntu 24.04 LTS in ap-south-1

  instance_type          = "t3.micro"

  subnet_id              = aws_subnet.tushar_subnet.id

  vpc_security_group_ids = [aws_security_group.tushar_sg.id]

  associate_public_ip_address = true

  key_name               = "terraform-keypair"  # your existing keypair name

  tags = {

    Name = "TusharEC2"

  }

}
 
