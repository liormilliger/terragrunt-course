# Zero to Hero: Terragrunt Course

This repository documents a hands-on journey through **Terragrunt**, an infrastructure-as-code wrapper for Terraform. It moves from basic DRY (Don't Repeat Yourself) principles to a full production-grade stack deployment (VPC + EKS) using dependency management and registry modules.

The course is divided into stages, each corresponding to a specific git commit in this repository's history.

## 📋 Prerequisites
* **Terraform** (v1.5+)
* **Terragrunt** (v0.60+)
* **AWS CLI** (Configured with Administrator credentials)
* **Kubernetes (kubectl)** (For final verification)

---

## 🚀 Course Progression

### Stage 1: The DRY Architecture
**Commit:** `Child-Parent` (Jan 12, 2026)

**The Problem:** In standard Terraform, managing multiple environments (dev, stage, prod) requires copying `provider` and `backend` blocks into every root module.
**The Solution:** We utilize Terragrunt's **Parent-Child inheritance**.

* **Key Concepts:**
    * `include "root"`: Inheriting configuration from a parent folder.
    * `find_in_parent_folders()`: Dynamic path resolution.
    * `generate`: Injecting `provider.tf` files on the fly to avoid hardcoding.

**Commands:**
```bash
cd live/dev
terragrunt init
terragrunt plan

```

---

### Stage 2: Remote State Management

**Commit:** `Adding root backend to all environments` (Jan 13, 2026)

**The Problem:** Managing the `terraform.tfstate` file locally is insecure and prevents collaboration. Setting up an S3 backend manually creates a "chicken-and-egg" problem.
**The Solution:** We configure the backend **once** in the root `terragrunt.hcl`.

* **Key Concepts:**
* `remote_state`: Auto-generates the `backend.tf` file.
* **Auto-Creation:** Terragrunt automatically provisions the S3 Bucket (state) and DynamoDB Table (locking) if they don't exist.
* `path_relative_to_include()`: Ensures unique state keys (e.g., `dev/terraform.tfstate`) for every environment automatically.



**Commands:**

```bash
terragrunt init
# (Terragrunt prompts to create the S3 bucket automatically)

```

---

### Stage 3: Dependencies & Stack Connection

**Commit:** `Connecting Stacks` (Jan 13, 2026)

**The Problem:** Infrastructure components rarely live in isolation. An App module needs to know the ID of an S3 Bucket module, but they have separate state files.
**The Solution:** We use Terragrunt `dependency` blocks to pass outputs between modules.

* **Key Concepts:**
* `dependency "name"`: Reads the remote state of another module.
* `mock_outputs`: Allows `plan` commands to succeed even if the dependency hasn't been deployed yet.
* **Input Mapping:** `vpc_id = dependency.vpc.outputs.vpc_id`.



**Commands:**

```bash
cd live/dev/app
terragrunt apply
# (Automatically reads outputs from the s3 component)

```

---

### Stage 4: The Production Capstone (VPC + EKS)

**Current State / Final Implementation**

**The Goal:** Deploy a complete modern tech stack using official Terraform Registry modules without writing raw Terraform code.
**The Architecture:**

* **Network:** AWS VPC (Official Module)
* **Compute:** AWS EKS Cluster (Kubernetes 1.35)
* **Key Concepts:**
* `tfr:///`: Consuming modules directly from the Terraform Registry.
* `run-all`: Orchestrating the deployment of the entire stack (VPC -> EKS) in the correct dependency order.
* **Patching:** Using `generate` to overwrite version constraints in upstream modules to resolve provider conflicts.



**How to Deploy:**

```bash
cd live/dev

# 1. Initialize and upgrade dependencies (handles provider conflicts)
cd eks && terragrunt init -upgrade && cd ..

# 2. Deploy the full stack
terragrunt run --all apply

```

**Verification:**
To verify the dependency injection worked (EKS actually connected to the VPC):

```bash
cd eks
terragrunt state show 'module.eks.aws_eks_cluster.this[0]'
# Look for vpc_config -> vpc_id

```

---

## 🧹 Cleanup

To destroy all resources and avoid AWS costs:

```bash
cd live/dev
terragrunt run --all destroy

```