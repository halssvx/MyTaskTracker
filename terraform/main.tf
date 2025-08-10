provider "aws" {
  region = var.region
}

# ------------------------
# VPC + Networking
# ------------------------
resource "aws_vpc" "main" {
  cidr_block           = "10.1.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

# Public Subnet 1 (AZ a)
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.1.1.0/24"
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true
}

# Public Subnet 2 (AZ b)
resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.1.2.0/24"
  availability_zone       = "${var.region}b"
  map_public_ip_on_launch = true
}

# Private Subnet 1 (AZ a)
resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.1.3.0/24"
  availability_zone = "${var.region}a"
}

# Private Subnet 2 (AZ b)
resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.1.4.0/24"
  availability_zone = "${var.region}b"
}


# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

# Public Route Table
resource "aws_route_table" "rt_public" {
  vpc_id = aws_vpc.main.id
}

# Public Route
resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.rt_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# Associate Public Subnets
resource "aws_route_table_association" "public_assoc_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.rt_public.id
}

resource "aws_route_table_association" "public_assoc_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.rt_public.id
}

# ------------------------
# Security Groups
# ------------------------
resource "aws_security_group" "ec2_sg" {
  name        = "ec2-sg"
  vpc_id      = aws_vpc.main.id
  description = "Allow HTTP and SSH"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "rds-sg"
  vpc_id      = aws_vpc.main.id
  description = "Allow MySQL from EC2"

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ------------------------
# RDS MySQL
# ------------------------
resource "aws_db_subnet_group" "main" {
  name       = "main-subnet-group"
  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]
}

resource "aws_db_instance" "mysql" {
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  #name                   = "tasktracker"
  username               = "admin"
  password               = var.db_password
  parameter_group_name   = "default.mysql8.0"
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot    = true
  publicly_accessible    = true
}

# ------------------------
# EC2 Instance
# ------------------------
resource "aws_instance" "ec2" {
  ami           = "ami-01776cde0c6f0677c" # Amazon Linux 2 in eu-west-1
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.public_a.id
  security_groups = [aws_security_group.ec2_sg.id]
  key_name      = var.key_name

   user_data = <<-EOF
              #!/bin/bash
              yum update -y
              amazon-linux-extras install docker -y
              service docker start
              usermod -a -G docker ec2-user
              chkconfig docker on

              docker run -d \
                -p 3000:3000 \
                -e DB_HOST=${aws_db_instance.mysql.address} \
                -e DB_USER=admin \
                -e DB_PASSWORD=${var.db_password} \
                -e DB_NAME=tasktracker \
                your-dockerhub-username/smart-task-tracker:latest
              EOF
  tags = {
    Name = "SmartTaskTrackerEC2"
  }
}
