
# Define main resources (ECS,EC2,S3,...)
# It's Project core

resource "aws_ecs_cluster" "app" {
  name = "spring-app-cluster"
}

resource "aws_s3_bucket" "logs" {
    bucket  =   "my-app-logs-bucket"
    acl = "private"

}