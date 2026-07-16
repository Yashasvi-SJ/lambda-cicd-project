resource "aws_s3_bucket" "frontend_bucket" {
  bucket = "yashasvi-demo-frontend-20260716"
}


resource "aws_s3_object" "index" {

  bucket = aws_s3_bucket.frontend_bucket.bucket

  key = "index.html"

  source = "frontend/index.html"

  content_type = "text/html"

}