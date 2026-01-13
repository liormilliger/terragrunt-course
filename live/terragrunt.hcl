remote_state {
    backend = "s3"
    generate = {
        path = "backend.tf"
        if_exists = "overwrite_terragrunt"
    }
    config = {
        bucket = "tg-course-state-${get_aws_account_id()}"
        key = "${path_relative_to_include()}/terraform.tfstate"
        region = "us-east-2"
        encrypt = true
        dynamodb_table = "tg_course_locks"
    }
}

generate "provider" {
    path      = "provider.tf"
    if_exists = "overwrite_terragrunt"
    contents  = <<EOF
provider "aws" {
    region = "us-east-2"
}
EOF
}

