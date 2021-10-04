resource "aws_ecr_repository" "app" {
  name = var.app_name
}

resource "aws_ecs_cluster" "app" {
  name = var.app_name
}

# The main service.
resource "aws_ecs_service" "app" {
  name            = var.app_name
  task_definition = aws_ecs_task_definition.app.arn
  cluster         = aws_ecs_cluster.app.id
  launch_type     = "FARGATE"

  desired_count = local.desired_count

  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = var.app_name
    container_port   = var.app_port
  }

  network_configuration {
    assign_public_ip = false
    security_groups  = [aws_security_group.app.id]
    subnets          = aws_subnet.private.*.id
  }
}

# basic task def
resource "aws_ecs_task_definition" "app" {
  family                   = var.app_name
  execution_role_arn       = aws_iam_role.app_ecs.arn
  cpu                      = 256
  memory                   = 512
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  container_definitions = jsonencode([
    {
      name      = var.app_name
      image     = "${aws_ecr_repository.app.repository_url}:latest"
      cpu       = var.app_cpu
      memory    = var.app_mem
      essential = true
      portMappings = [{
        containerPort = var.app_port
      }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-region        = local.region
          awslogs-group         = aws_cloudwatch_log_group.app.name
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}
