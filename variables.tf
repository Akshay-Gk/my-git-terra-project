variable "project_name" {

  description = "my project name"
  type        = string
  default     = "zomato"
}

variable "project_environment" {

  description = "my project environment"
  type        = string
  default     = "prod"
}

variable "vpc_cidr_block" {

  type    = string
  default = "172.16.0.0/16"
}

variable "main_cidr_block" {

  default = "172.16.0.0/16"
}

variable "region" {

  type    = string
  default = "ap-south-1"
}
