include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/app-config"
}

# This block reads the outputs from the s3 component
dependency "bucket" {
  config_path = "../s3"
}

inputs = {
  # We extract the output from the dependency and pass it to the variable
  s3_bucket_id = dependency.bucket.outputs.bucket_id
}
