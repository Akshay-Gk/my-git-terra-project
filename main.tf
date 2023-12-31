#vpc creation

resource "aws_vpc" "my-vpc" {
  cidr_block           = var.vpc_cidr_block
  instance_tenancy     = "default"
  enable_dns_hostnames = "true"

  tags = {
    Name        = "${var.project_name}-${var.project_environment}"
    Environment = var.project_environment
    Project     = var.project_name
  }
}

#igw creation

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my-vpc.id

  tags = {
    Name        = "${var.project_name}-${var.project_environment}"
    Environment = var.project_environment
    Project     = var.project_name
  }
}
#public subnets creation
 
resource "aws_subnet" "public" {
 
  count                   = 3
  vpc_id                  = aws_vpc.my-vpc.id
  cidr_block              = cidrsubnet(var.main_cidr_block, 3, (count.index + 3))
  map_public_ip_on_launch = "true"
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name        = "${var.project_name}-${var.project_environment}-public${count.index + 4}"
    Environment = var.project_environment
    Project     = var.project_name
  }
}


#private subnets creation
 
resource "aws_subnet" "private" {
 
  count                   = 3
  vpc_id                  = aws_vpc.my-vpc.id
  cidr_block              = cidrsubnet(var.main_cidr_block, 3, (count.index))
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = "false"
 
  tags = {
    Name        = "${var.project_name}-${var.project_environment}-private${count.index + 1}"
    Environment = var.project_environment
    Project     = var.project_name
  }
}

#elstic-ip  creation
 
resource "aws_eip" "nat" {
 
  domain = "vpc"
}
 
#nat-gw creation
 
resource "aws_nat_gateway" "my-nat" {
 
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[2].id
 
  tags = {
    Name        = "${var.project_name}-${var.project_environment}"
    Environment = var.project_environment
    Project     = var.project_name
  }
 
  depends_on = [aws_internet_gateway.igw]
}

#public route table creation
 
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.my-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name        = "${var.project_name}-${var.project_environment}-public"
    Environment = var.project_environment
    Project     = var.project_name
  }
}

#private route table creation
 
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.my-vpc.id
 
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.my-nat.id
  }
 
  tags = {
    Name        = "${var.project_name}-${var.project_environment}-private"
    Environment = var.project_environment
    Project     = var.project_name
  }
}



#private route table assosciation
 
resource "aws_route_table_association" "private" {
 
  count          = 3
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
 
#public route table assosciation
 
resource "aws_route_table_association" "public" {
 
  count          = 3
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}


#bastion security group creation

resource "aws_security_group" "bastion" {
  name_prefix = "${var.project_name}-${var.project_environment}-bastion"
  description = "Allow shh from all"
  vpc_id      = aws_vpc.my-vpc.id

  ingress {
    description      = "allow ssh from all"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name        = "${var.project_name}-${var.project_environment}-bastion"
    Environment = var.project_environment
    Project     = var.project_name
  }

}
