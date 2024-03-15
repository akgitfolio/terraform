# Configure the AWS provider
provider "aws" {
  region = "us-west-2"
}

# Create a VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags       = { Name = "main-vpc" }
}

# Create a Subnet
resource "aws_subnet" "main" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-west-2a"
  tags              = { Name = "main-subnet" }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "main-igw" }
}

# Create a Route Table
resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = { Name = "main-route-table" }
}

# Associate the Route Table with the Subnet
resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.main.id
}

# Create a Security Group
resource "aws_security_group" "main" {
  vpc_id = aws_vpc.main.id
  ingress {
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
  tags = { Name = "main-security-group" }
}

# Create an EC2 Instance
resource "aws_instance" "app" {
  ami             = "ami-0c55b159cbfafe1f0"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.main.id
  security_groups = [aws_security_group.main.name]
  tags            = { Name = "AppInstance" }
}

# Create an S3 Bucket
resource "aws_s3_bucket" "app" {
  bucket = "my-unique-bucket-name-12345"
  acl    = "private"
  tags   = { Name = "AppBucket" }
}

# Create an RDS Instance
resource "aws_db_instance" "app" {
  identifier             = "app-db"
  allocated_storage      = 20
  engine                 = "mysql"
  instance_class         = "db.t2.micro"
  username               = "admin"
  password               = "password"
  parameter_group_name   = "default.mysql8.0"
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.main.id]
  tags                   = { Name = "app-db" }
}

# Create a Customer Gateway
resource "aws_customer_gateway" "main" {
  bgp_asn    = 65000
  ip_address = "198.51.100.1"
  type       = "ipsec.1"
  tags       = { Name = "main-customer-gateway" }
}

# Create a VPN Connection
resource "aws_vpn_connection" "main" {
  customer_gateway_id = aws_customer_gateway.main.id
  vpn_gateway_id      = aws_vpn_gateway.main.id
  type                = "ipsec.1"
  static_routes_only  = true
  tags                = { Name = "main-vpn-connection" }
}

# Create VPN Connection Route
resource "aws_vpn_connection_route" "main" {
  vpn_connection_id      = aws_vpn_connection.main.id
  destination_cidr_block = "192.168.1.0/24"
}
