# ami for EC2 instance
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# Tech Challenge 3 EC2 Instance
resource "aws_instance" "proj_3" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  subnet_id                   = data.aws_subnet.public.id
  associate_public_ip_address = true
  key_name                    = "P3"

  vpc_security_group_ids = [
    aws_security_group.this.id
  ]

  depends_on = [aws_route.public_internet]

  tags = {
    Name        = "${var.project_name}-ec2"
    Environment = var.environment
    Project     = "Tech-Challenge-3"

  }
}

# This will use the default VPC in the AWS account
data "aws_vpc" "default" {
  default = true
}

# Use the existing project subnet in the default VPC.
data "aws_subnet" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  filter {
    name   = "cidr-block"
    values = ["172.31.96.0/20"]
  }
}

# Use the Internet Gateway already attached to the default VPC.
data "aws_internet_gateway" "public" {
  filter {
    name   = "attachment.vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Use the route table already associated with the project subnet.
data "aws_route_table" "public" {
  filter {
    name   = "association.subnet-id"
    values = [data.aws_subnet.public.id]
  }
}

# Add internet access to the subnet's existing route table.
resource "aws_route" "public_internet" {
  route_table_id         = data.aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = data.aws_internet_gateway.public.id
}

# Security Group for EC2 Instance
resource "aws_security_group" "this" {
  name        = "tech-challenge-3-sg"
  description = "Security group for Tech Challenge 3 EC2 instance"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
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
    Name        = "${var.project_name}-sg"
    Environment = var.environment
    Project     = "Tech-Challenge-3"
  }
}
