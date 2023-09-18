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


