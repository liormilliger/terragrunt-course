include "root" {
  path = find_in_parent_folders()
}

terraform {
  # This can be a local path, a Git URL, or a Registry URL
  source = "../../modules/s3-greeter"
}

inputs = {
  # These match the variable names in variables.tf
  environment  = "dev"
  student_name = "lior" # Optional, since you have a default
}
