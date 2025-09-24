variable "aws_region" {
  description = "AWS region for the infrastructure"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "A unique name for the project to prefix resources"
  type        = string
  default     = "staging-eks-demo"
}

variable "instance_types" {
  description = "List of EC2 instance types for the node group"
  type        =  list(string)
  default     = ["t3.medium"]
}
variable "cluster_version" {
  description = "Kubernetes version for EKS"
  type        = string
  default     = "1.31"
}
