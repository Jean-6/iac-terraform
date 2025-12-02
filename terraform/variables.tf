# Declare all variables used into project 

variable "aws_region" {
  description = "AWS region where to deploy resources"
  type = string
  default = "eu-west-1"
}

variable "aws_profile" {
    description = "AWS CLI Profile to use"
    type = string
    default = "default"
}

variable "vpc_cidr" {
  description = "CIDR du VPC"
  type = string
  default = "10.0.0.0/16"
}