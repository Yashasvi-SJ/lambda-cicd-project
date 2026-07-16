resource "aws_s3_bucket" "frontend_bucket" {
  bucket = "yashasvi-demo-frontend-20260716"
}


resource "aws_s3_object" "index" {

  bucket = aws_s3_bucket.frontend_bucket.bucket

  key = "index.html"

  source = "frontend/index.html"

  content_type = "text/html"

}
data "aws_iam_policy_document" "frontend_policy" {

  statement {

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${aws_s3_bucket.frontend_bucket.arn}/*"
    ]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"

      values = [
        aws_cloudfront_distribution.website.arn
      ]
    }
  }
}

resource "aws_s3_bucket_policy" "frontend_policy" {

  bucket = aws_s3_bucket.frontend_bucket.id

  policy = data.aws_iam_policy_document.frontend_policy.json
}