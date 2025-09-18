variable "project_name" {
  description = "Name of the project"
  type        = string
  default="staging-eks-demo"
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for the EKS cluster and nodes"
  type        = list(string)
}

variable "instance_types" {
  description = "List of EC2 instance types for the node group"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "desired_size" {
  description = "Desired number of worker nodes"
  type        = number
}

variable "max_size" {
  description = "Maximum number of worker nodes"
  type        = number
}

variable "min_size" {
  description = "Minimum number of worker nodes"
  type        = number
}