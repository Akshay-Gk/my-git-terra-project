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
