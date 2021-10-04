resource "aws_cloudwatch_log_group" "app" {
  name = "/ecs/${var.app_name}"
}
