resource "aws_vpc" "Tenacity-IT-Group-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "Tenacity-IT-Group-vpc"
  }
}

# aws public subnet
resource "aws_subnet" "Prod-pub-subnet-1" {
  vpc_id     = aws_vpc.Tenacity-IT-Group-vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Prod-pub-subnet-1"
  }
}

# aws public subnet
resource "aws_subnet" "Prod-pub-subnet-2" {
  vpc_id     = aws_vpc.Tenacity-IT-Group-vpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "Prod-pub-subnet-2"  }
}

# aws private subnet
resource "aws_subnet" "Prod-priv-subnet-1" {
  vpc_id     = aws_vpc.Tenacity-IT-Group-vpc.id
  cidr_block = "10.0.3.0/24"

  tags = {
    Name = "Prod-priv-subnet-1"
  }
}

# aws private subnet
resource "aws_subnet" "Prod-priv-subnet-2" {
  vpc_id     = aws_vpc.Tenacity-IT-Group-vpc.id
  cidr_block = "10.0.4.0/24"

  tags = {
    Name = "Prod-priv-subnet-2"
  }
}

# aws public route
resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.Tenacity-IT-Group-vpc.id

  tags = {
    Name = "public-route-table"
  }
}

# aws private route
resource "aws_route_table" "private-route-table" {
  vpc_id = aws_vpc.Tenacity-IT-Group-vpc.id

  tags = {
    Name = "private-route-table"
  }
}

#aws private route association
resource "aws_route_table_association" "private-route-table" {
  subnet_id      = aws_subnet.Prod-priv-subnet-1.id
  route_table_id = aws_route_table.private-route-table.id
}

#aws private route association
resource "aws_route_table_association" "private-route-table-association" {
  subnet_id      = aws_subnet.Prod-priv-subnet-2.id
  route_table_id = aws_route_table.private-route-table.id
}

# aws public route table association
resource "aws_route_table_association" "public-route-table" {
  subnet_id      = aws_subnet.Prod-pub-subnet-1.id
  route_table_id = aws_route_table.public-route-table.id
}

# aws public route table association
resource "aws_route_table_association" "public-route-table-association" {
  subnet_id      = aws_subnet.Prod-pub-subnet-2.id
  route_table_id = aws_route_table.public-route-table.id
}

# aws IGW
resource "aws_internet_gateway" "Prod-igw-association" {
  vpc_id = aws_vpc.Tenacity-IT-Group-vpc.id

  tags = {
    Name = "Prod-igw-association"
  }
}

# aws route for igw & public route table
resource "aws_route" "public-internet-igw" {
  route_table_id            = aws_route_table.public-route-table.id
  destination_cidr_block    = "0.0.0.0/0"
gateway_id                  = aws_internet_gateway.Prod-igw-association.id
}

# Create Elastic IP Address
resource "aws_eip" "Prod-IP" {
  tags = {
    Name = "Prod-teIP"
  }
}

# Create NAT Gateway
resource "aws_nat_gateway" "Prod-nat-gateway" {
  allocation_id = aws_eip.Prod-IP.id
  subnet_id     = aws_subnet.Prod-pub-subnet-1.id

  tags = {
    Name = "Prod-nat-gateway"
  }

}

# NAT Associate with Priv route
resource "aws_route" "private-route" {
  route_table_id = aws_route_table.private-route-table.id
  gateway_id = aws_nat_gateway.Prod-nat-gateway.id
  destination_cidr_block = "0.0.0.0/0"
}