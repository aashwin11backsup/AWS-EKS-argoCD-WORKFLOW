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

  project_name         = var.project_name
  cluster_version      = var.cluster_version
  private_subnet_ids   = module.vpc.private_subnet_ids
  instance_types=      var.instance_types
  
  # Node group scaling
  desired_size         = 2
  max_size             = 3
  min_size             = 1
}



#----------- Changing the Code after [LOCAL CONNECTION TO THE CLUSTER]--------------------

# Data source to retrieve the default aws-auth config from the cluster.

data "aws_eks_cluster_auth" "main" {
  name = module.eks.cluster_name
}


resource "kubernetes_config_map_v1_data" "aws_auth" {
  # This depends on the Kubernetes provider configured in providers.tf
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    "mapUsers" = yamlencode(
      # We merge the default EKS node mapping with our new admin user mapping
      union(
        yamldecode(data.aws_eks_cluster_auth.main.value).mapUsers,
        [
          {
            # ARN is passed dynamically from the workflow
            userarn  = var.cluster_creator_arn
            # extracting the username from the full ARN
            username = split("/", var.cluster_creator_arn)[1]

            groups   = ["system:masters"]
          }
        ]
      )
    )
  }


  depends_on = [module.eks]
}