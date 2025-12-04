# Declare all variables used into project 

variable "aws_region" {
  description = "AWS region where to deploy resources"
  type = string
  default = "eu-west-1"
}


variable "account_id" {
  type = string
}

variable "app_name" {
  type = string
  default = "vegnbio-api"
}

variable "image_tag" {
  type = string
  default = "1.0.0"
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

#
variable "vpc_id" { # from network.tf ou outputs.tf
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "private_subnet_ids" {
  type = list(string)
}