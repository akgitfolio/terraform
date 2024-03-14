# Configure the AWS provider
provider "aws" {
  region = "us-west-2" # Replace with your desired AWS region
}

# Create a VPC
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

# Create an Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }
}

# Create a Route Table
resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "main-route-table"
  }
}

# Associate the Route Table with the Subnet
resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.main.id
}

# Create a Virtual Private Gateway
resource "aws_vpn_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-vpn-gateway"
  }
}

# Create a Customer Gateway
resource "aws_customer_gateway" "main" {
  bgp_asn    = 65000          # Replace with your BGP ASN
  ip_address = "198.51.100.1" # Replace with your on-premises public IP
  type       = "ipsec.1"

  tags = {
    Name = "main-customer-gateway"
  }
}

# Create a VPN Connection
resource "aws_vpn_connection" "main" {
  customer_gateway_id = aws_customer_gateway.main.id
  vpn_gateway_id      = aws_vpn_gateway.main.id
  type                = "ipsec.1"

  static_routes_only = true

  tags = {
    Name = "main-vpn-connection"
  }
}

# Create VPN Connection Route
resource "aws_vpn_connection_route" "main" {
  vpn_connection_id      = aws_vpn_connection.main.id
  destination_cidr_block = "192.168.1.0/24" # Replace with your on-premises network CIDR block
}

# Output the VPN connection configuration
output "vpn_connection_config" {
  value = aws_vpn_connection.main.customer_gateway_configuration
}
