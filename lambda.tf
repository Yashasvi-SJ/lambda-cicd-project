resource "aws_lambda_layer_version" "python_layer" {
  layer_name = "python-layer"

  s3_bucket = aws_s3_bucket.artifact_bucket.bucket
  s3_key    = "layer.zip"

  compatible_runtimes = ["python3.9"]
}
resource "aws_iam_role" "lambda_role" {

  name = "lambda-role"

  assume_role_policy = jsonencode({

    Version = "2012-10-17"

    Statement = [

      {

        Action = "sts:AssumeRole"

        Effect = "Allow"

        Principal = {

          Service = "lambda.amazonaws.com"

        }

      }

    ]

  })

}
resource "aws_iam_role_policy_attachment" "lambda_policy" {

  role = aws_iam_role.lambda_role.name

  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"

}
resource "aws_lambda_function" "demo_lambda" {

  function_name = "demo-lambda"

  role = aws_iam_role.lambda_role.arn

  handler = "lambda_function.lambda_handler"

  runtime = "python3.9"

  s3_bucket = aws_s3_bucket.artifact_bucket.bucket

  s3_key = "function.zip"

  layers = [

    aws_lambda_layer_version.python_layer.arn

  ]

}
