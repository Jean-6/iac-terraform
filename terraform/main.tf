
# Define main resources (ECS,EC2,S3,...)
# It's Project core

# ECR repository
resource "aws_ecr_repository" "app" { #Private registry which contains docker image of app
  name = var.app_name
  image_scanning_configuration {
    scan_on_push = true
  }
  tags = {
    Environment = "dev"
  }
}

#ECS cluster
resource "aws_ecs_cluster" "cluster" { # Cluster AWS ECR in which fargate containers will turn
  name = "${var.app_name}-cluster"
}

# IAM role for task execution (Fargate needs this)
resource "aws_iam_role" "ecs_task_execution" { # ECS needs a rule to retrieve image into ECR, describe logs into CloudWatch, and execute task
  name = "${var.app_name}-ecs-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
}

data "aws_iam_policy_document" "ecs_task_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_attachment" {
  role   = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


# Security group for service (allow HTTP)
resource "aws_security_group" "ecs_sg" { # Authorize traffic from LB to container
  name        = "${var.app_name}-sg"
  description = "Allow HTTP to ECS tasks"
  vpc_id = aws_vpc.main.id

  ingress {
    description = "HTTP from ALB"
    from_port   = 8082
    to_port     = 8082
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # if public service, else restrict

  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#Application Load Balancer
resource "aws_lb" "alb" { # Distribute traffic between containers ,
  name = "vegnbio-api-alb"
  internal = false
  load_balancer_type = "application"
  subnets            = [
    aws_subnet.public_1.id,
    aws_subnet.public_2.id
  ]
  security_groups = [aws_security_group.alb_sg.id]
}

resource "aws_security_group" "alb_sg" { # Authorize public access HTTP and give public DNS to access to app
  name ="${var.app_name}-alb-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Target group
resource "aws_lb_target_group" "tg" { # LB send HTTP traffic to TG, TG redirect to Fargate container
  name = "${var.app_name}-tg"
  port = 8082
  protocol = "HTTP"
  vpc_id = aws_vpc.main.id

  target_type = "ip"

  health_check {
    path = "/actuator/health"
    matcher = "200-399"
    interval = 30
    healthy_threshold = 2
    unhealthy_threshold = 3
  }
}

resource "aws_lb_listener" "http" { # listen port 80, redirect to Target Group
  load_balancer_arn = aws_lb.alb.arn
  port = "80"
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

# ECS task definition (Fargate)
resource "aws_ecs_task_definition" "task" { # Define docker container to launch (ECR image, port, memory/cpu, health check, logs)
  family                = "${var.app_name}-task"
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "512"
  memory = "1024"
  execution_role_arn = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([
    {
      name = var.app_name
      image = "${var.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${aws_ecr_repository.app.name}:${var.image_tag}"
      essential = true

      environment = [
        {
          name = "SPRING_PROFILES_ACTIVE"
          value = "prod"
        },
        {
          name = "MONGO_URI"
          value = mongodbatlas_cluster.cluster.connection_strings[0].standard_srv
        },
        {
          name = "JWT_SECRET"
          value = var.jwt_secret
        },
        {
          name = "JWT_EXPIRATION"
          value = "86400000"
        }
      ]

      portMappings = [
        {
          containerPort = 8082
          hostPort = 8082
          protocol = "tcp"
        }
      ]
      healthCheck = {
        command = ["CMD-SHELL", "curl -f http://localhost:8082/actuator/health || exit 1"]
        interval = 30
        timeout = 5
        retries = 3
        startPeriod = 10
      }
    }
  ])
}


# ECS service
resource "aws_ecs_service" "service" { # create and maintain containers automatically, connexion with LB, auto-scaling possible
  name = "${var.app_name}-service"
  cluster = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task.arn
  desired_count = 1
  launch_type = "FARGATE"

  network_configuration {
    subnets = [
      aws_subnet.public_1.id,
      aws_subnet.public_2.id
    ]
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.tg.arn
    container_name = "vegnbio-api"
    container_port = 8082
  }

  depends_on = [
    aws_lb_listener.http
  ]

}



