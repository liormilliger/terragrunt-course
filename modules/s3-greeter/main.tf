resource "aws_s3_bucket" "this" {
  bucket = "${var.environment}-tg-course-${var.student_name}"
  
  tags = {
    Name        = "Terragrunt Course"
    Environment = var.environment
    GeneratedBy = "Terragrunt"
  }
}

output "bucket_id" {
  value = aws_s3_bucket.this.id
}

output "success_token" {
  # This logic creates the hidden proof string
  value = sha256("${aws_s3_bucket.this.id}-verified")
}