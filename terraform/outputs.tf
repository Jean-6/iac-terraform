# To expose useful informations after deployment

output "vpc_id" {
  description = "ID of VPC created"
  value = "aws_vpc.main.id"
}

output "ecs_cluster_ name" {
  description = "Name of ECS cluster"
  value = "aws_ecs_cluster.app.name"
}