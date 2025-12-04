

- Created ECR repository for Docker images
- Added ECS cluster and Fargate service
- Configured IAM execution roles for ECS tasks
- Added Application Load Balancer + target group + listener
- Added security groups for ALB and ECS tasks
- Added task definition with container settings and health checks

terraform init
terraform validate

terraform plan

terraform apply

#### Supprime les ressources incomplètes ou conflictuelles
terraform destroy