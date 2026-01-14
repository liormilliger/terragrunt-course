variable "s3_bucket_id" {
  type = string
}

resource "local_file" "config" {
  content  = "The app should upload logs to: ${var.s3_bucket_id}"
  filename = "${path.module}/app-config.txt"
}

output "config_path" {
  value = local_file.config.filename
}
