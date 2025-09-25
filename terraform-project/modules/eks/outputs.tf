output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  description = "The endpoint for the EKS cluster"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_ca_certificate" {
  description = "The CA certificate for the EKS cluster"
  value       = aws_eks_cluster.main.certificate_authority[0].data
}


output "node_role_arn" {
  description = "The ARN of the IAM role for the worker nodes."
  value       = aws_iam_role.node_role.arn
}