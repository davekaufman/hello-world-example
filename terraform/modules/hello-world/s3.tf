resource "aws_s3_bucket" "lb_logs" {
  bucket = "${var.org_name}-${var.app_name}-lb-logs"
  acl    = "private"

  tags = merge(
    {
      Name = "${var.org_name}-${var.app_name}-lb-logs"
    },
    var.tags
  )
}

# no reason for this bucket to ever be public
resource "aws_s3_bucket_public_access_block" "lb_logs" {
  bucket = aws_s3_bucket.lb_logs.id

  block_public_acls   = true
  block_public_policy = true

  depends_on = [aws_s3_bucket_policy.lb_logs]
}

# grant access to lb to write logs
resource "aws_s3_bucket_policy" "lb_logs" {
  bucket = aws_s3_bucket.lb_logs.id
  policy = data.aws_iam_policy_document.lb_logs_bucket_policy.json
}
