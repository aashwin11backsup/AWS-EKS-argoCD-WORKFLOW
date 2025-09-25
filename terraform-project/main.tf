# --- Data sources to get available AZs in the chosen region ---
data "aws_availability_zones" "available" {
  state = "available"
}

# --- Local variables for networking configuration ---
locals {
  vpc_cidr             = "10.0.0.0/16"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.101.0/24", "10.0.102.0/24"]
  availability_zones   = slice(data.aws_availability_zones.available.names, 0, 2)
}

# --- Networking Module ---
module "vpc" {
  source = "./modules/vpc"

  project_name         = var.project_name
  vpc_cidr             = local.vpc_cidr
  public_subnet_cidrs  = local.public_subnet_cidrs
  private_subnet_cidrs = local.private_subnet_cidrs
  availability_zones   = local.availability_zones
}

# --- EKS Cluster Module ---
module "eks" {
  source = "./modules/eks"

  project_name       = var.project_name
  cluster_version    = var.cluster_version
  private_subnet_ids = module.vpc.private_subnet_ids
  instance_types     = var.instance_types
  
  # Node group scaling
  desired_size       = 2
  max_size           = 3
  min_size           = 1
}




# ------------------------------------------------------------------
# --- EKS AUTHENTICATION - Grant access to the cluster creator ---
# ------------------------------------------------------------------

# STEP 1: READ the existing aws-auth ConfigMap. This block was missing.
data "kubernetes_config_map_v1" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }
  # Ensures we wait for the cluster to be ready before trying to read the map
  depends_on = [module.eks]
}

# STEP 2: MODIFY the data in the ConfigMap.
resource "kubernetes_config_map_v1_data" "aws_auth_patch" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  # This allows Terraform to manage this specific field without conflicts
  field_manager = "terraform-provider-kubernetes"
  force         = true # Takes ownership of the data field

  data = {
    "mapUsers" = yamlencode(
      # setunion combines the lists and removes any duplicates.
      setunion(
        # Use try() to provide a default empty list if the ConfigMap isn't ready.
        try(yamldecode(data.kubernetes_config_map_v1.aws_auth.data.mapUsers), []),
        [
          {
            # ARN is passed dynamically from the workflow
            userarn  = var.cluster_creator_arn
            # Extracts the username (e.g., "ItAdmin") from the full ARN
            username = split("/", var.cluster_creator_arn)[1]
            # Grants full cluster-admin permissions
            groups   = ["system:masters"]
          }
        ]
      )
    )
  }
}