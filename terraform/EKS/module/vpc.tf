
resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr_block
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = var.vpc_name
    Env  = var.env
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = var.igw_name
    Env  = var.env
    "kubernetes.io/cluster/${local.cluster_name}" = "owned"
  }
}

resource "aws_subnet" "public_subnet" {
  count                   = var.pub_subnet_count
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = element(var.pub_cidr_block, count.index)
  availability_zone       = element(var.pub_availability_zone, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.pub_sub_name}-${count.index + 1}"
    Env  = var.env
    "kubernetes.io/cluster/${local.cluster_name}" = "owned"
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_subnet" "private_subnet" {
  count                   = var.pri_subnet_count
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = element(var.pri_cidr_block, count.index)
  availability_zone       = element(var.pri_availability_zone, count.index)
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.pri_sub_name}-${count.index + 1}"
    Env  = var.env
    "kubernetes.io/cluster/${local.cluster_name}" = "owned"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = var.public_rt_name
    Env  = var.env
  }
}

resource "aws_route_table_association" "public_assoc" {
  count          = var.pub_subnet_count
  route_table_id = aws_route_table.public_rt.id
  subnet_id      = aws_subnet.public_subnet[count.index].id
}

resource "aws_eip" "ngw_eip" {
  domain = "vpc"

  tags = {
    Name = var.eip_name
  }
}

resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.ngw_eip.allocation_id
  subnet_id     = aws_subnet.public_subnet[0].id

  tags = {
    Name = var.ngw_name
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw.id
  }

  tags = {
    Name = var.private_rt_name
    Env  = var.env
  }
}

resource "aws_route_table_association" "private_assoc" {
  count          = var.pri_subnet_count
  route_table_id = aws_route_table.private_rt.id
  subnet_id      = aws_subnet.private_subnet[count.index].id
}

resource "aws_security_group" "eks_cluster_sg" {
  name        = var.eks_sg
  description = "Allow 443 from Jump server only"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0", "10.1.0.0/16", "132.23.45.34/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.eks_sg
  }
}