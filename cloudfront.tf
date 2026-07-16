resource "aws_cloudfront_distribution" "website" {

  enabled = true

  origin {

    domain_name = aws_s3_bucket.frontend_bucket.bucket_regional_domain_name

    origin_id = "frontend"

  }

  default_cache_behavior {

    allowed_methods = ["GET", "HEAD"]

    cached_methods = ["GET", "HEAD"]

    target_origin_id = "frontend"

    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {

      query_string = false

      cookies {

        forward = "none"

      }

    }

  }

  restrictions {

    geo_restriction {

      restriction_type = "none"

    }

  }

  viewer_certificate {

    cloudfront_default_certificate = true

  }

}