

### 0. Install official provider of MongoDB Atlas

### 1. Create ECR repository
aws ecr create-repository --repository-name vegn-bio-api --region $AWS_REGION

### 2. Build local
docker build -t vegn-bio-api:1.0.0 .

### 3. Tag image for ECR
docker tag vegn-bio-api:1.0.0 $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/vegn-bio-api:1.0.0

### 4. Login ECR
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

### 5. Push
docker push $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/vegn-bio-api:1.0.0


### 6. Terraform project


- Created ECR repository for Docker images
- Added ECS cluster and Fargate service
- Configured IAM execution roles for ECS tasks
- Added Application Load Balancer + target group + listener
- Added security groups for ALB and ECS tasks
- Added task definition with container settings and health checks

### 7. Terraform command

- terraform init
- terraform validate
- terraform plan
- terraform apply
- terraform destroy (delete incomplete conflictual resource)

