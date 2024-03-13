# Configure the AWS provider
provider "aws" {
  region = "us-west-2" # Replace with your desired AWS region
}

# Create a VPC (optional but recommended)
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "main-vpc"
  }
}

# Create a Subnet
resource "aws_subnet" "main" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "main-subnet"
  }
}

# Create a Security Group
resource "aws_security_group" "main" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 3306 # Replace with your database port (e.g., 5432 for PostgreSQL)
    to_port     = 3306 # Replace with your database port (e.g., 5432 for PostgreSQL)
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
    Name = "main-security-group"
  }
}

# Create an RDS Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "main-subnet-group"
  subnet_ids = [aws_subnet.main.id]

  tags = {
    Name = "main-subnet-group"
  }
}

# Create an RDS Instance
resource "aws_db_instance" "app" {
  identifier             = "app-db"
  allocated_storage      = 20
  engine                 = "mysql" # Replace with your desired database engine (e.g., "postgres", "mysql")
  instance_class         = "db.t2.micro"
  username               = "admin"
  password               = "password"         # Use sensitive data management (e.g., Terraform variables) for production
  parameter_group_name   = "default.mysql8.0" # Replace with the appropriate parameter group for your engine
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.main.id]

  tags = {
    Name = "app-db"
  }
}

# Output the RDS endpoint
output "db_endpoint" {
  value = aws_db_instance.app.endpoint
}
