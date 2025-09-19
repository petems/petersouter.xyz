provider "aws" {
  region  = var.region
  version = "2.70.4"
}

resource "aws_iam_user" "circleci" {
  name = "circleci"
  path = "/"
}

resource "aws_iam_access_key" "circleci" {
  user = aws_iam_user.circleci.name
}

resource "aws_iam_user_policy" "circleci" {
  name = "circleci"
  user = aws_iam_user.circleci.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
          "s3:ListBucket",
          "s3:GetBucketLocation"
      ],
      "Resource": ["arn:aws:s3:::${var.s3_bucket_name}"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:PutObjectAcl",
        "s3:GetObject",
        "s3:DeleteObject"
      ],
      "Resource": ["arn:aws:s3:::${var.s3_bucket_name}/*"]
    }
  ]
}
EOF

}

