# To expose useful informations after deployment

#output "vpc_id" {
#  description = "ID of VPC created"
#  value = "aws_vpc.main.id"
#}

#output "ecs_cluster_ name" {
#  description = "Name of ECS cluster"
#  value = "aws_ecs_cluster.app.name"
#}



output "ecr_repo_url" {
  value = aws_ecr_repository.app.repository_url
}

output "alb_arn" {
  value = aws_lb.alb.arn
}

output "alb_dns" {
  value = aws_lb.alb.dns_name
}