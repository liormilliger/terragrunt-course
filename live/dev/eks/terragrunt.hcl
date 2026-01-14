include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "tfr:///terraform-aws-modules/eks/aws?version=19.15.3"
}

dependency "vpc" {
  config_path = "../vpc"

  # MOCK OUTPUTS: This allows you to run 'plan' without actually applying the VPC first.
  # Terragrunt will use these fake values for the plan.
  mock_outputs = {
    vpc_id          = "vpc-fake-id-123"
    private_subnets = ["subnet-fake-1", "subnet-fake-2"]
  }
}

inputs = {
  cluster_name    = "tg-course-cluster"
  cluster_version = "1.34"

  cluster_endpoint_public_access = true

  # Here we map the dependency outputs to the module inputs
  vpc_id     = dependency.vpc.outputs.vpc_id
  subnet_ids = dependency.vpc.outputs.private_subnets

  # Minimal node group to prove it works
  eks_managed_node_groups = {
    green = {
      min_size     = 1
      max_size     = 2
      desired_size = 1

      instance_types = ["t3.medium"]
    }
  }
}

generate "versions" {
  path      = "versions.tf"
  if_exists = "overwrite"
  contents  = <<EOF
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
EOF
}
