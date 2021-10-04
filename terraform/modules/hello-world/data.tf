data "aws_region" "current" {}
data "aws_elb_service_account" "main" {}
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_iam_policy_document" "app_ecs_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "app_ecs_policy" {
  statement {
    sid = "GetCallerIdentity" # example permission, remove later and replace with real access perms as necessary

    actions = [
      "sts:GetCallerIdentity"
    ]

    resources = [
      "*"
    ]
  }
}

data "aws_iam_policy_document" "lb_logs_bucket_policy" {
  policy_id = "s3_bucket_lb_logs"

  statement {
    actions = [
      "s3:PutObject",
    ]
    effect = "Allow"
    resources = [
      "${aws_s3_bucket.lb_logs.arn}/*",
    ]

    principals {
      identifiers = ["${data.aws_elb_service_account.main.arn}"]
      type        = "AWS"
    }
  }

  statement {
    actions = [
      "s3:PutObject"
    ]
    effect    = "Allow"
    resources = ["${aws_s3_bucket.lb_logs.arn}/*"]
    principals {
      identifiers = ["delivery.logs.amazonaws.com"]
      type        = "Service"
    }
  }


  statement {
    actions = [
      "s3:GetBucketAcl"
    ]
    effect    = "Allow"
    resources = ["${aws_s3_bucket.lb_logs.arn}"]
    principals {
      identifiers = ["delivery.logs.amazonaws.com"]
      type        = "Service"
    }
  }
}
