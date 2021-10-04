resource "aws_iam_role" "app_ecs" {
  name               = "${var.app_name}-ecs"
  assume_role_policy = data.aws_iam_policy_document.app_ecs_role.json
}

resource "aws_iam_policy" "app_ecs" {
  name   = "${var.app_name}-ecs"
  path   = "/"
  policy = data.aws_iam_policy_document.app_ecs_policy.json
}

resource "aws_iam_role_policy_attachment" "app_ecs" {
  role       = aws_iam_role.app_ecs.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# default aws task execution policy
resource "aws_iam_role_policy_attachment" "app_ecs_task_execution_role" {
  role       = aws_iam_role.app_ecs.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
