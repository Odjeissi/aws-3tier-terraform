# AWS Iam role Resource

resource "aws_iam_role" "role" {
  name = var.role_name

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = var.assume_role_policy.Action
        Effect = var.assume_role_policy.Effect
        Principal = {
          Service = var.assume_role_policy.Principal.Service
        }
      },
    ]
  })

  tags = {
    Name        = "${var.env}-${var.role_name}"
    Environment = var.env
  }
}

resource "aws_iam_role_policy_attachment" "test-attach" {
  for_each   = var.policy_arn
  role       = aws_iam_role.role.name
  policy_arn = each.value
}
