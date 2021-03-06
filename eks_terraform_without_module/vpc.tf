// VPC
resource "aws_vpc" "vpc" {
  cidr_block           = var.main_network_block
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = map(
    "Name", "${var.cluster_name}_vpc",
    "kubernetes.io/cluster/${var.cluster_name}", "shared"
  )
}


// Public Subnet
resource "aws_subnet" "public_subnet" {
  count  = length(var.public_subnet_cidr_block)
  vpc_id = aws_vpc.vpc.id
  //cidr_block              = var.public_subnet_cidr_block[count.index]
  cidr_block              = element(var.public_subnet_cidr_block, count.index)
  availability_zone       = var.available_azs[count.index]
  map_public_ip_on_launch = true

  tags = {
    "Name"                                      = "${var.cluster_name}_public_subnet_${count.index + 1}"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }
}

// Private Subnet
resource "aws_subnet" "private_subnet" {
  count  = length(var.private_subnet_cidr_block)
  vpc_id = aws_vpc.vpc.id
  //cidr_block              = var.private_subnet_cidr_block[count.index]
  cidr_block              = element(var.private_subnet_cidr_block, count.index)
  availability_zone       = var.available_azs[count.index]
  map_public_ip_on_launch = false

  tags = {
    "Name"                                      = "${var.cluster_name}_private_subnet_${count.index + 1}"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  }
}


// Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    "Name" = "${var.cluster_name}_igw"
  }
}

// Elastic IP
# Create EIP for Nat Gateway
resource "aws_eip" "eip" {
  vpc = true
}

// NAT GW
# Create Nat Gateway
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public_subnet.0.id

  tags = {
    "Name" = "${var.cluster_name}_nat_gw"
  }
}


// Route table >> public
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    "Name" = "${var.cluster_name}_public_rt"
  }
}

// Route table >> private
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    "Name" = "${var.cluster_name}_private_rt"
  }
}


// Public Subnet route table association
resource "aws_route_table_association" "public_rt_asso" {
  count = length(var.public_subnet_cidr_block)

  subnet_id      = aws_subnet.public_subnet.*.id[count.index]
  route_table_id = aws_route_table.public_rt.id
}

// Private Subnet route table association
resource "aws_route_table_association" "private_rt_asso" {
  count = length(var.private_subnet_cidr_block)

  subnet_id      = aws_subnet.private_subnet.*.id[count.index]
  route_table_id = aws_route_table.private_rt.id
}