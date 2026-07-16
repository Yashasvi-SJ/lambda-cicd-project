output "cloudfront_url" {

  value = aws_cloudfront_distribution.website.domain_name

}
output "lambda_name" {

  value = aws_lambda_function.demo_lambda.function_name

}